import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllTransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date; // Use DateTime as the standard type inside your app
  final String remarks;
  final bool expense;
  final DateTime? createdAt;

  AllTransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.remarks,
    required this.expense,
    this.createdAt,
  });

  // --- CHANGE 1: RENAME THIS METHOD ---
  // This is used ONLY for saving data to Firestore.
  Map<String, dynamic> toFirestoreMap() {
    return {
      "title": title,
      "amount": amount,
      "category": category,
      "date": Timestamp.fromDate(date), // Correct for Firestore
      "remarks": remarks,
      "expense": expense,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // --- CHANGE 2: CREATE A NEW toMap FOR CACHING ---
  // This is used for saving data to local JSON/cache.
  // It converts DateTime to a simple integer.
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "amount": amount,
      "category": category,
      "date": date.millisecondsSinceEpoch, // Save as an integer
      "remarks": remarks,
      "expense": expense,
      "createdAt": createdAt?.millisecondsSinceEpoch, // Save as an integer
    };
  }

  // --- CHANGE 3: MAKE fromMap MORE ROBUST ---
  // This factory will now correctly handle data coming from either
  // Firestore (as a Timestamp) or your local cache (as an int).
  factory AllTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return AllTransactionModel(
      id: id,
      title: map["title"] ?? "",
      amount: (map["amount"] as num?)?.toDouble() ?? 0.0,
      category: map["category"] ?? "",
      date: _parseDate(map["date"]) ?? DateTime.now(), // Ensure non-null DateTime
      remarks: map["remarks"] ?? "",
      expense: map["expense"] ?? false,
      createdAt: _parseDate(map["createdAt"]), // Also use it for createdAt
    );
  }

  // --- CHANGE 4: ADD THE HELPER FUNCTION ---
  // This private helper function makes the fromMap factory clean and readable.
  static DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is Timestamp) {
      return dateValue.toDate(); // Handles data from Firestore
    }
    if (dateValue is int) {
      // Handles data from your cache (millisecondsSinceEpoch)
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    // Fallback for string dates if you ever use them
    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }
    // Return null if the type is unknown
    return null;
  }

  AllTransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? remarks,
    bool? expense,
    DateTime? createdAt,
  }) {
    return AllTransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      remarks: remarks ?? this.remarks,
      expense: expense ?? this.expense,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}