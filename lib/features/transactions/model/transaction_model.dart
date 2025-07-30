class TransactionModel {
  final String title;
  final String amount;
  final String category;
  final String? date;
  final String remarks;
  final bool expense;
  final String id;

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
    final result = <String, dynamic>{};
    result.addAll({"title": title});
    result.addAll({'amount': amount});
    result.addAll({'category': category});
    result.addAll({'date': date});
    result.addAll({'remarks': remarks});
    result.addAll({'expense': expense});

    return result;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      title: map["title"] ?? "",
      amount: map['amount'] ?? '',
      category: map['category'] ?? '',
      date: map["date"] ?? "",
      remarks: map['remarks'] ?? '',
      expense: map['expense'] ?? false,
    );
  }

  TransactionModel copyWith({
    String? title,
    String? amount,
    String? category,
    String? date,
    String? remarks,
    bool? expense,
    String? id,
  }) {
    return TransactionModel(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      remarks: remarks ?? this.remarks,
      expense: expense ?? this.expense,
      id: id ?? this.id,
    );
  }
}
