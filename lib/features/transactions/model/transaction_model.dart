import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String remarks;
  final bool expense; // true = expense, false = income

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.remarks,
    required this.expense,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "amount": amount,
      "category": category,
      "date": Timestamp.fromDate(date),
      "remarks": remarks,
      "expense": expense,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      title: map["title"] ?? "",
      amount: (map["amount"] as num?)?.toDouble() ?? 0.0,
      category: map["category"] ?? "",
      date: map["date"] is Timestamp
          ? (map["date"] as Timestamp).toDate()
          : DateTime.tryParse(map["date"]?.toString() ?? "") ?? DateTime.now(),
      remarks: map["remarks"] ?? "",
      expense: map["expense"] ?? false,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? remarks,
    bool? expense,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      remarks: remarks ?? this.remarks,
      expense: expense ?? this.expense,
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}
