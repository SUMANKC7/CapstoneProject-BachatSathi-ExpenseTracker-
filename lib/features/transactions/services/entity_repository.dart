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

  /// Initialize SharedPreferences
  static Future<SharedPreferences> initSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  /// Add a new entity with robust offline support
  Future<void> addEntity({
    required String name,
    required String phone,
    required String openingBalance,
    required String date,
    required String email,
    required String address,
    required bool isCreditInfoSelected,
    required bool toReceive,
    required String category,
  }) async {
    final entityData = {
      'name': name,
      'phone': phone,
      'openingBalance': double.tryParse(openingBalance) ?? 0,
      'date': date,
      'email': email,
      'address': address,
      'isCreditInfoSelected': isCreditInfoSelected,
      'toReceive': toReceive,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'status': toReceive
          ? TransactionStatus.toReceive.toString()
          : TransactionStatus.toGive.toString(),
    };

    try {
      await _firestore.collection('Entities').add(entityData);
      await _updateLocalCache();
    } catch (e) {
      debugPrint('Online add failed, caching offline: $e');
      await _cacheOfflineOperation(type: 'add', data: entityData);
      throw Exception('Operation queued for sync when online');
    }
  }

  /// Fetch entities with proper caching
  Future<List<AddParty>> fetchEntities() async {
    try {
      final snapshot = await _firestore
          .collection('Entities')
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));

      final parties = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data.isEmpty) throw Exception('Empty document data');
        return AddParty.fromFirestore(data, doc.id);
      }).toList();

      await cacheEntities(parties);
      return parties;
    } catch (e) {
      debugPrint('Fetch failed, using cache: $e');
      return await getCachedEntities();
    }
  }

  /// Stream of entities with real-time updates
  Stream<List<AddParty>> listenToEntities() {
    return _firestore
        .collection('Entities')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .asyncMap((snapshot) async {
          final parties = snapshot.docs.map((doc) {
            return AddParty.fromFirestore(doc.data(), doc.id);
          }).toList();

          if (!snapshot.metadata.isFromCache) {
            await cacheEntities(parties);
          }
          return parties;
        });
  }

  /// Get cached entities
  // In EntityRepositoryService.dart

  // In EntityRepositoryService.dart

  Future<List<AddParty>> getCachedEntities() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(
      'cached_parties',
    ); // Or whatever your key is
    if (cachedData == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(cachedData);

    // THIS IS THE FIX! Use the factory designed for cache data.
    return jsonList.map((json) => AddParty.fromCacheJson(json)).toList();
  }

  /// Delete entity with offline support
  Future<void> deleteEntity(String id) async {
    try {
      await _firestore.collection('Entities').doc(id).delete();
      await _updateLocalCache();
    } catch (e) {
      debugPrint('Online delete failed, caching offline: $e');
      await _cacheOfflineOperation(type: 'delete', data: {'id': id});
      throw Exception('Delete queued for sync when online');
    }
  }

  /// Public method to cache entities
  Future<void> cacheEntities(List<AddParty> parties) async {
    try {
      final jsonList = parties.map((party) => party.toCacheJson()).toList();
      await _prefs.setString(_localStorageKey, json.encode(jsonList));
      await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Cache error: $e');
      throw Exception('Failed to cache entities');
    }
  }

  /// Check if there are pending offline operations
  bool hasPendingOperations() {
    return (_prefs.getStringList(_offlineOperationsKey)?.isNotEmpty ?? false);
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _prefs.remove(_localStorageKey);
    await _prefs.remove(_lastSyncKey);
    await _prefs.remove(_offlineOperationsKey);
  }

  /// Check network connectivity
  Future<bool> isOnline() async {
    try {
      await _firestore
          .collection('Entities')
          .limit(1)
          .get(const GetOptions(source: Source.server));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Process pending offline operations
  Future<void> processOfflineOperations() async {
    final operations = _prefs.getStringList(_offlineOperationsKey) ?? [];
    if (operations.isEmpty) return;

    for (final op in operations) {
      try {
        final decoded = json.decode(op) as Map<String, dynamic>;
        final type = decoded['type'] as String;
        final data = decoded['data'] as Map<String, dynamic>;

        switch (type) {
          case 'add':
            await _firestore.collection('Entities').add(data);
            break;
          case 'delete':
            await _firestore.collection('Entities').doc(data['id']).delete();
            break;
        }
      } catch (e) {
        debugPrint('Failed to process offline op: $e');
        continue;
      }
    }

    await _prefs.remove(_offlineOperationsKey);
    await _updateLocalCache();
  }

  // Private methods
  Future<void> _updateLocalCache() async {
    try {
      final parties = await fetchEntities();
      await cacheEntities(parties);
    } catch (e) {
      debugPrint('Cache update failed: $e');
    }
  }

  Future<void> _cacheOfflineOperation({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final operations = _prefs.getStringList(_offlineOperationsKey) ?? [];
      operations.add(json.encode({'type': type, 'data': data}));
      await _prefs.setStringList(_offlineOperationsKey, operations);
    } catch (e) {
      debugPrint('Failed to cache offline op: $e');
      throw Exception('Failed to queue offline operation');
    }
  }
}
