import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/transaction_model.dart';

class TransactionDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  bool isExpense = false;
  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<String> incomeCategories = ["Salary", "Business", "Gift", "Others"];
  List<String> expenseCategories = ["Food", "Transport", "Bills", "Others"];

  TransactionDataProvider() {
    _listenToTransactions(); // ✅ start listening immediately
  }

  /// 🔹 Listen to Firestore updates (works offline too)
  void _listenToTransactions() {
    _firestore
        .collection('Transactions')
        .orderBy('date', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
          _transactions = snapshot.docs.map((doc) {
            final data = doc.data();
            return TransactionModel.fromMap(data, doc.id);
          }).toList();

          notifyListeners();
        });
  }

  /// 🔹 Set transaction type (income or expense)
  void setTransactionType(bool expense) {
    isExpense = expense;
    notifyListeners();
  }

  /// 🔹 Set category
  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  /// 🔹 Pick date
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  /// 🔹 Format date for display
  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// 🔹 Get formatted selected date
  String get formattedSelectedDate {
    return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  }

  /// 🔹 Add new transaction
  Future<void> addTransaction() async {
    await _firestore.collection('Transactions').add({
      'title': titleController.text,
      'amount': double.tryParse(amountController.text) ?? 0,
      'remarks': descriptionController.text,
      'category': selectedCategory,
      'expense': isExpense,
      'date': selectedDate,
    });
    clearForm();
  }

  /// 🔹 Clear form fields
  void clearForm() {
    titleController.clear();
    amountController.clear();
    descriptionController.clear();
    selectedCategory = '';
    selectedDate = DateTime.now();
    isExpense = false;
    notifyListeners();
  }
}
