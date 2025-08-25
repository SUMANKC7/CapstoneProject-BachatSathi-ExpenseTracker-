import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AllTransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String remarks;
  final bool expense; // true = expense, false = income
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

  // --- THIS IS THE CRITICAL FIX ---
  // The 'toMap()' method now includes the 'id' field.
  // This is used to prepare data for the background PDF generation.
  Map<String, dynamic> toMap() {
    return {
      'id': id, // THIS LINE WAS MISSING
      'title': title,
      'amount': amount,
      'category': category,
      'remarks': remarks,
      'expense': expense,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }
  
  // This method is for saving to FIRESTORE. It should remain the same.
  Map<String, dynamic> toFirestoreMap() {
    return {
      "title": title,
      "amount": amount,
      "category": category,
      "date": Timestamp.fromDate(date),
      "remarks": remarks,
      "expense": expense,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // This factory is now robust for loading from Firestore or the cache.
  factory AllTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return AllTransactionModel(
      id: id,
      title: map["title"] ?? "",
      amount: (map["amount"] as num?)?.toDouble() ?? 0.0,
      category: map["category"] ?? "",
      date: _parseDate(map["date"]) ?? DateTime.now(),
      remarks: map["remarks"] ?? "",
      expense: map["expense"] ?? false,
      createdAt: _parseDate(map["createdAt"]),
    );
  }

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
    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }
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