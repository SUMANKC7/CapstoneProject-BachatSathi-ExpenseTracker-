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

  Map<String, dynamic> toMap() {
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

  factory AllTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return AllTransactionModel(
      id: id,
      title: map["title"] ?? "",
      amount: (map["amount"] as num?)?.toDouble() ?? 0.0,
      category: map["category"] ?? "",
      date: map["date"] is Timestamp
          ? (map["date"] as Timestamp).toDate()
          : DateTime.tryParse(map["date"]?.toString() ?? "") ?? DateTime.now(),
      remarks: map["remarks"] ?? "",
      expense: map["expense"] ?? false,
      createdAt: map["createdAt"] is Timestamp 
          ? (map["createdAt"] as Timestamp).toDate()
          : null,
    );
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