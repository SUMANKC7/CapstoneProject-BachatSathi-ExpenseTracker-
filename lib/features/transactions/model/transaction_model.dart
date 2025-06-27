

class TransactionModel {
  final String amount;
  final String category;
  final String date;
  final String description;
  final bool expense;
  
  TransactionModel({
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.expense,
  });
  

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    result.addAll({'amount': amount});
    result.addAll({'category': category});
    result.addAll({'date': date});
    result.addAll({'description': description});
    result.addAll({'expense': expense});
  
    return result;
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      amount: map['amount'] ?? '',
      category: map['category'] ?? '',
      date: map["date"]??"",
      description: map['description'] ?? '',
      expense: map['expense'] ?? false,
    );
  }

}
