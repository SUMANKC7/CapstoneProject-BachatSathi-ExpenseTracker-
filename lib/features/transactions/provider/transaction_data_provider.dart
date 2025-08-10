import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDataProvider extends ChangeNotifier {
  final CollectionReference _firebaseFirestore = FirebaseFirestore.instance
      .collection("Transactions");

  List<TransactionModel> _transactions = [];
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = "categories";

  List<TransactionModel> get transactions => _transactions;
  TextEditingController get titleController => _titleController;
  TextEditingController get amountController => _amountController;
  TextEditingController get descriptionController => _descriptionController;
  DateTime get selectedDate => _selectedDate;
  String get selectedCategory => _selectedCategory;
  bool get isExpense => _isExpense;

  List<TransactionModel> get incomeTransactions =>
      _transactions.where((t) => !t.expense).toList();

  List<TransactionModel> get expenseTransactions =>
      _transactions.where((t) => t.expense).toList();

  String get formattedSelectedDate =>
      DateFormat('dd MMM yyyy').format(_selectedDate);

  final List<String> expenseCategories = [
    "Food",
    "Clothes",
    "Game",
    "Rent",
    "Entertainment",
  ];
  final List<String> incomeCategories = [
    "Salary",
    "Investment",
    "Commission",
    "Interest",
    "Gift",
  ];
  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> fetchTransactions() async {
    listenToTransactions();
  }

  void setCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setTransactionType(bool expense) {
    _isExpense = expense;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2060),
    );

    if (picked != null) {
      _selectedDate = picked;
      notifyListeners();
    }
  }

  // String get formattedDate {
  //   // If you want to show a placeholder when no date is chosen
  //   return DateFormat('dd MMM yyyy').format(_selectedDate);
  // }

  Future<void> addTransaction() async {
    try {
      final transactionData = TransactionModel(
        id: "",
        title: _titleController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        category: _selectedCategory,
        date: _selectedDate,
        remarks: _descriptionController.text,
        expense: _isExpense,
      );

      final docRef = await _firebaseFirestore.add(transactionData.toMap());

      _transactions.add(transactionData.copyWith(id: docRef.id));

      _titleController.clear();
      _amountController.clear();
      _descriptionController.clear();
      _selectedCategory = "categories";

      notifyListeners();
    } catch (e) {
      log("Error adding transaction: $e");
    }
  }

  void listenToTransactions() {
    _firebaseFirestore.orderBy('date', descending: true).snapshots().listen((
      snapshot,
    ) {
      _transactions = snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
