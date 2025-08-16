import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddTransactionRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localStorageKey = 'cached_transactions';
  static const String _lastSyncKey = 'last_sync';

  AddTransactionRepo() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Add a new transaction to Firestore
  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String remarks,
    required bool expense,
  }) async {
    try {
      print('Repository addTransaction called with:');
      print('Title: $title');
      print('Amount: $amount');
      print('Category: $category');
      print('Date: $date');
      print('Remarks: $remarks');
      print('Expense: $expense');

      // Create transaction data map directly
      final transactionData = {
        'title': title,
        'amount': amount,
        'category': category.isEmpty ? 'General' : category,
        'date': Timestamp.fromDate(date),
        'remarks': remarks,
        'expense': expense,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print('Transaction data prepared: $transactionData');

      // Add to Firestore
      final docRef = await _firestore
          .collection('Transactions')
          .add(transactionData);

      print('Document added with ID: ${docRef.id}');

      // Update the document with its ID
      await docRef.update({'id': docRef.id});

      print('Document ID updated successfully');

      // Update local cache
      await _updateLocalCache();

      print('Local cache updated');
    } catch (e) {
      print("Firestore Add Error: $e");
      print("Stack trace: ${StackTrace.current}");
      throw Exception("Failed to add transaction: $e");
    }
  }

  /// Listen to all transactions in real-time with offline support
  Stream<List<AllTransactionModel>> listenToTransactions() {
    return _firestore
        .collection('Transactions')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          final transactions = snapshot.docs.map((doc) {
            return AllTransactionModel.fromMap(doc.data(), doc.id);
          }).toList();

          if (!snapshot.metadata.isFromCache) {
            _cacheTransactionsLocally(transactions);
          }

          return transactions;
        });
  }

  /// Get a single transaction by ID
  Future<AllTransactionModel?> getTransactionById(String transactionId) async {
    try {
      print('Repository getTransactionById called with ID: $transactionId');

      final doc = await _firestore
          .collection('Transactions')
          .doc(transactionId)
          .get();

      if (doc.exists && doc.data() != null) {
        return AllTransactionModel.fromMap(doc.data()!, doc.id);
      } else {
        print('Transaction with ID $transactionId not found');
        return null;
      }
    } catch (e) {
      print('Error getting transaction by ID: $e');
      throw Exception("Failed to get transaction: $e");
    }
  }

  /// Get cached transactions when offline
  Future<List<AllTransactionModel>> getCachedTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_localStorageKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((item) {
          return AllTransactionModel.fromMap(
            Map<String, dynamic>.from(item),
            item['id'] ?? '',
          );
        }).toList();
      }
    } catch (e) {
      print('Error loading cached transactions: $e');
    }

    return [];
  }

  /// Delete transaction by ID
  Future<void> deleteTransaction(String id) async {
    try {
      print('Repository deleteTransaction called with ID: $id');

      await _firestore.collection('Transactions').doc(id).delete();

      print('Transaction deleted successfully from Firestore');

      await _updateLocalCache();

      print('Local cache updated after deletion');
    } catch (e) {
      print('Error deleting transaction: $e');
      throw Exception("Failed to delete transaction: $e");
    }
  }

  /// Update transaction
  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      print('Repository updateTransaction called with ID: $id');
      print('Update data: $data');

      // Ensure updated date is stored as Timestamp if provided
      if (data.containsKey('date') && data['date'] is DateTime) {
        data['date'] = Timestamp.fromDate(data['date']);
      }

      // Add updatedAt timestamp
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('Transactions').doc(id).update(data);

      print('Transaction updated successfully in Firestore');

      await _updateLocalCache();

      print('Local cache updated after update');
    } catch (e) {
      print('Error updating transaction: $e');
      throw Exception("Failed to update transaction: $e");
    }
  }

  /// Batch update multiple transactions (useful for bulk operations)
  Future<void> batchUpdateTransactions(
    List<Map<String, dynamic>> updates,
  ) async {
    try {
      final batch = _firestore.batch();

      for (var update in updates) {
        final id = update['id'];
        final data = Map<String, dynamic>.from(update);
        data.remove('id');

        if (data.containsKey('date') && data['date'] is DateTime) {
          data['date'] = Timestamp.fromDate(data['date']);
        }

        data['updatedAt'] = FieldValue.serverTimestamp();

        batch.update(_firestore.collection('Transactions').doc(id), data);
      }

      await batch.commit();
      await _updateLocalCache();

      print('Batch update completed successfully');
    } catch (e) {
      print('Error in batch update: $e');
      throw Exception("Failed to batch update transactions: $e");
    }
  }

  /// Batch delete multiple transactions
  Future<void> batchDeleteTransactions(List<String> transactionIds) async {
    try {
      final batch = _firestore.batch();

      for (String id in transactionIds) {
        batch.delete(_firestore.collection('Transactions').doc(id));
      }

      await batch.commit();
      await _updateLocalCache();

      print('Batch delete completed successfully');
    } catch (e) {
      print('Error in batch delete: $e');
      throw Exception("Failed to batch delete transactions: $e");
    }
  }

  /// Cache transactions locally
  Future<void> _cacheTransactionsLocally(
    List<AllTransactionModel> transactions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = transactions.map((
        transaction,
      ) {
        final map = transaction.toMap();
        map['id'] = transaction.id;
        return map;
      }).toList();

      await prefs.setString(_localStorageKey, json.encode(jsonList));
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching transactions: $e');
    }
  }

  /// Update local cache
  Future<void> _updateLocalCache() async {
    try {
      final snapshot = await _firestore
          .collection('Transactions')
          .orderBy('createdAt', descending: true)
          .get();

      final transactions = snapshot.docs.map((doc) {
        return AllTransactionModel.fromMap(doc.data(), doc.id);
      }).toList();

      await _cacheTransactionsLocally(transactions);
    } catch (e) {
      print('Error updating local cache: $e');
    }
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      await _firestore
          .collection('Transactions')
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

  /// Get transactions by category
  Future<List<AllTransactionModel>> getTransactionsByCategory(
    String category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('Transactions')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AllTransactionModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting transactions by category: $e');
      throw Exception("Failed to get transactions by category: $e");
    }
  }

  /// Get transactions within date range
  Future<List<AllTransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('Transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AllTransactionModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error getting transactions by date range: $e');
      throw Exception("Failed to get transactions by date range: $e");
    }
  }
}
