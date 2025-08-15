import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/transactions/model/party_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EntityRepositoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localStorageKey = 'cached_entities';
  static const String _lastSyncKey = 'last_sync';

  EntityRepositoryService() {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Add a new entity to Firestore
  Future<void> addEntity({
    required String name,
    required String phone,
    required String openingBalance,
    required String date,
    required String email,
    required String address,
    required bool isCreditInfoSelected,
    required bool toReceive,
  }) async {
    try {
      final entityData = {
        'name': name,
        'phone': phone,
        'openingBalance': double.tryParse(openingBalance) ?? 0,
        'date': date,
        'email': email,
        'address': address,
        'isCreditInfoSelected': isCreditInfoSelected,
        'toReceive': toReceive,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Entities').add(entityData);

      // Update local cache
      await _updateLocalCache();
    } catch (e) {
      throw Exception("Failed to add entity: $e");
    }
  }

  /// Listen to all entities in real-time with offline support
  Stream<List<AddParty>> listenToEntities() {
    return _firestore
        .collection('Entities')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          final parties = snapshot.docs.map((doc) {
            return AddParty.fromFirestore(doc.data(), doc.id);
          }).toList();

          // Cache data locally when online
          if (!snapshot.metadata.isFromCache) {
            _cacheEntitiesLocally(parties);
          }

          return parties;
        });
  }

  /// Get cached entities when offline
  Future<List<AddParty>> getCachedEntities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_localStorageKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((item) {
          return AddParty.fromFirestore(
            Map<String, dynamic>.from(item),
            item['id'],
          );
        }).toList();
      }
    } catch (e) {
      print('Error loading cached entities: $e');
    }

    return [];
  }

  /// Delete entity by ID
  Future<void> deleteEntity(String id) async {
    try {
      await _firestore.collection('Entities').doc(id).delete();
      await _updateLocalCache();
    } catch (e) {
      throw Exception("Failed to delete entity: $e");
    }
  }

  /// Update entity
  Future<void> updateEntity(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('Entities').doc(id).update(data);
      await _updateLocalCache();
    } catch (e) {
      throw Exception("Failed to update entity: $e");
    }
  }

  /// Cache entities locally
  Future<void> _cacheEntitiesLocally(List<AddParty> parties) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = parties.map((party) {
        return {
          'id': party.id,
          'name': party.name,
          'phone': party.phone,
          'email': party.email,
          'address': party.address,
          'openingBalance': party.openingBalance,
          'date': party.date,
          'isCreditInfoSelected': party.isCreditInfoSelected,
          'toReceive': party.toReceive,
          'createdAt': party.createdAt?.millisecondsSinceEpoch,
        };
      }).toList();

      await prefs.setString(_localStorageKey, json.encode(jsonList));
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching entities: $e');
    }
  }

  /// Update local cache
  Future<void> _updateLocalCache() async {
    try {
      final snapshot = await _firestore
          .collection('Entities')
          .orderBy('createdAt', descending: true)
          .get();

      final parties = snapshot.docs.map((doc) {
        return AddParty.fromFirestore(doc.data(), doc.id);
      }).toList();

      await _cacheEntitiesLocally(parties);
    } catch (e) {
      print('Error updating local cache: $e');
    }
  }

  /// Check if device is online
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

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }
}
