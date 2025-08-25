import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EntityRepositoryService {
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;
  static const String _localStorageKey = 'cached_entities';
  static const String _lastSyncKey = 'last_sync';
  static const String _offlineOperationsKey = 'offline_operations';

  EntityRepositoryService({
    FirebaseFirestore? firestore,
    required SharedPreferences prefs,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _prefs = prefs {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Add Entity From Party
  Future<void> addEntityFromParty(AddParty party) async {
    try {
      debugPrint('🔄 Repository: Adding entity ${party.name}');
      
      final docRef = await _firestore
          .collection('Entities')
          .add(party.toFirestoreMap());
      
      debugPrint('✅ Repository: Entity added successfully with ID: ${docRef.id}');

      // Update local cache after successful add
      await _updateLocalCache();
    } catch (e) {
      debugPrint('❌ Repository: Online add failed, caching offline: $e');
      await _cacheOfflineOperation(type: 'add', data: party.toFirestoreMap());
      throw Exception('Operation queued for sync when online: ${e.toString()}');
    }
  }

  // Legacy method
  Future<void> addEntity(AddParty party) async {
    return addEntityFromParty(party);
  }

  // Fetch Entities from server
  Future<List<AddParty>> fetchEntities() async {
    try {
      debugPrint('🌐 Repository: Fetching entities from server...');
      
      final snapshot = await _firestore
          .collection('Entities')
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));

      debugPrint('📥 Repository: Got ${snapshot.docs.length} documents from server');

      final parties = <AddParty>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          // Ensure createdAt exists
          if (data['createdAt'] == null) {
            data['createdAt'] = Timestamp.now();
          }
          final party = AddParty.fromFirestore(data, doc.id);
          parties.add(party);
          debugPrint('  ✓ Parsed: ${party.name} (${party.id})');
        } catch (e) {
          debugPrint('  ❌ Failed to parse document ${doc.id}: $e');
        }
      }

      debugPrint('✅ Repository: Successfully parsed ${parties.length} parties');
      await cacheEntities(parties);
      return parties;
    } catch (e) {
      debugPrint('❌ Repository: Fetch from server failed: $e');
      return await getCachedEntities();
    }
  }

  // Real-time Stream with better error handling
  Stream<List<AddParty>> listenToEntities() {
    debugPrint('🎧 Repository: Setting up Firestore stream...');
    
    return _firestore
        .collection('Entities')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          debugPrint('📡 Repository: Stream update - ${snapshot.docs.length} docs, fromCache: ${snapshot.metadata.isFromCache}');
          
          final parties = <AddParty>[];
          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();

              // Ensure createdAt exists
              if (data['createdAt'] == null) {
                data['createdAt'] = Timestamp.now();
              }

              final party = AddParty.fromFirestore(data, doc.id);
              parties.add(party);
            } catch (e) {
              debugPrint('❌ Repository: Failed to parse document ${doc.id}: $e');
            }
          }

          debugPrint('✅ Repository: Stream processed ${parties.length} parties');

          // Update cache if data is from server (not from local cache)
          if (!snapshot.metadata.isFromCache && parties.isNotEmpty) {
            cacheEntities(parties).catchError((e) {
              debugPrint('⚠️ Repository: Cache update failed: $e');
            });
          }

          return parties;
        })
        .handleError((error) {
          debugPrint('❌ Repository: Stream error: $error');
          // Return empty list on error - let the provider handle fallback to cache
          return <AddParty>[];
        });
  }

  // Cache Entities
  Future<void> cacheEntities(List<AddParty> parties) async {
    try {
      debugPrint('💾 Repository: Caching ${parties.length} entities...');
      final jsonList = parties.map((p) => p.toCacheJson()).toList();
      await _prefs.setString(_localStorageKey, json.encode(jsonList));
      await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('✅ Repository: Cached ${parties.length} entities successfully');
    } catch (e) {
      debugPrint('❌ Repository: Cache error: $e');
    }
  }

  // Get Cached Entities
  Future<List<AddParty>> getCachedEntities() async {
    try {
      debugPrint('📂 Repository: Loading cached entities...');
      final cachedData = _prefs.getString(_localStorageKey);
      if (cachedData == null) {
        debugPrint('📭 Repository: No cached data found');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(cachedData);
      final parties = jsonList
          .map((json) => AddParty.fromCacheJson(json))
          .toList();

      // Sort cached data by createdAt descending
      parties.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.now();
        final bTime = b.createdAt ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      debugPrint('✅ Repository: Loaded ${parties.length} entities from cache');
      return parties;
    } catch (e) {
      debugPrint('❌ Repository: Error loading cached entities: $e');
      return [];
    }
  }

  // Delete Entity
  Future<void> deleteEntity(String id) async {
    try {
      debugPrint('🗑️ Repository: Deleting entity $id');
      await _firestore.collection('Entities').doc(id).delete();
      await _updateLocalCache();
      debugPrint('✅ Repository: Entity deleted successfully: $id');
    } catch (e) {
      debugPrint('❌ Repository: Online delete failed: $e');
      await _cacheOfflineOperation(type: 'delete', data: {'id': id});
      throw Exception('Delete queued for sync when online');
    }
  }

  // Check Online Status
  Future<bool> isOnline() async {
    try {
      await _firestore
          .collection('Entities')
          .limit(1)
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      debugPrint('📱 Repository: Offline mode detected: $e');
      return false;
    }
  }

  // Last Sync Time
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  // Cache offline operations
  Future<void> _cacheOfflineOperation({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final operations = _prefs.getStringList(_offlineOperationsKey) ?? [];
      final operation = {
        'type': type,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      operations.add(json.encode(operation));
      await _prefs.setStringList(_offlineOperationsKey, operations);
      debugPrint('💾 Repository: Cached offline operation: $type');
    } catch (e) {
      debugPrint('❌ Repository: Failed to cache offline operation: $e');
    }
  }

  // Process offline operations
  Future<void> processOfflineOperations() async {
    final operations = _prefs.getStringList(_offlineOperationsKey) ?? [];
    int processed = 0;

    for (final op in operations) {
      try {
        final decoded = json.decode(op) as Map<String, dynamic>;
        final type = decoded['type'] as String;
        final data = decoded['data'] as Map<String, dynamic>;

        switch (type) {
          case 'add':
            await _firestore.collection('Entities').add(data);
            processed++;
            break;
          case 'delete':
            await _firestore.collection('Entities').doc(data['id']).delete();
            processed++;
            break;
        }
      } catch (e) {
        debugPrint('❌ Repository: Failed to process offline operation: $e');
      }
    }

    if (processed > 0) {
      await _prefs.remove(_offlineOperationsKey);
      await _updateLocalCache();
      debugPrint('✅ Repository: Processed $processed offline operations');
    }
  }

  // Private: Update Cache
  Future<void> _updateLocalCache() async {
    try {
      debugPrint('🔄 Repository: Updating local cache...');
      final parties = await fetchEntities();
      debugPrint('✅ Repository: Updated local cache with ${parties.length} entities');
    } catch (e) {
      debugPrint('❌ Repository: Cache update failed: $e');
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_localStorageKey);
      await _prefs.remove(_lastSyncKey);
      await _prefs.remove(_offlineOperationsKey);
      debugPrint('✅ Repository: Cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Repository: Failed to clear cache: $e');
    }
  }
}