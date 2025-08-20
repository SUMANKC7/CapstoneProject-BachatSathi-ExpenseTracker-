import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/other_assets/model/financial_data_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic method to save data
  Future<void> saveData<T extends FinancialData>(
    String collection,
    String docId,
    T data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(docId)
          .set(data.toFirestore());
    } catch (e) {
      print('Error saving $collection data: $e');
      rethrow;
    }
  }

  // Check if data was fetched today
  Future<bool> isDataFetchedToday(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (!doc.exists) return false;

      final lastFetchDate = (doc.data()?['lastFetchDate'] as Timestamp?)
          ?.toDate();
      if (lastFetchDate == null) return false;

      final today = DateTime.now();
      final fetchDate = lastFetchDate;

      return today.year == fetchDate.year &&
          today.month == fetchDate.month &&
          today.day == fetchDate.day;
    } catch (e) {
      print('Error checking fetch date: $e');
      return false;
    }
  }

  // Get stocks stream
  Stream<List<StockData>> getStocksStream() {
    return _firestore
        .collection('stocks')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StockData.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // Get crypto stream
  Stream<List<CryptoData>> getCryptoStream() {
    return _firestore
        .collection('crypto')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CryptoData.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // Get gold stream
  Stream<List<GoldData>> getGoldStream() {
    return _firestore
        .collection('gold')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GoldData.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // Get currencies stream
  Stream<List<CurrencyExchangeData>> getCurrenciesStream() {
    return _firestore
        .collection('currencies')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CurrencyExchangeData.fromFirestore(doc.data()))
              .toList(),
        );
  }
}
