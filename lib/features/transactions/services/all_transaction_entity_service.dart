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
      await _firestore.collection('Transactions').doc(id).delete();
      await _updateLocalCache();
    } catch (e) {
      throw Exception("Failed to delete transaction: $e");
    }
  }

  /// Update transaction
  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    try {
      // Ensure updated date is stored as Timestamp if provided
      if (data.containsKey('date') && data['date'] is DateTime) {
        data['date'] = Timestamp.fromDate(data['date']);
      }

      await _firestore.collection('Transactions').doc(id).update(data);
      await _updateLocalCache();
    } catch (e) {
      throw Exception("Failed to update transaction: $e");
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
}
