import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionDataProvider extends ChangeNotifier {
  final CollectionReference _firebaseFirestore = FirebaseFirestore.instance
      .collection("Transactions");

  TransactionDataProvider();

  List<TransactionModel> _transactions = [];
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _income = false;
  String _selectedDate = "Date";
  String _expenseselectedcategory = "categories";
  String _incomeselectedcategory = "categories";

  String get selectedDate => _selectedDate;
  List<TransactionModel> get transactions => _transactions;
  TextEditingController get titleController => _titleController;
  TextEditingController get amountController => _amountController;
  TextEditingController get descriptionController => _descriptionController;

  // String get formattedDate => DateFormat("yyyy/MM/dd").format(_currentdate);
  bool get income => _income;

  final List<String> _expensecategories = [
    "Food",
    "Clothes",
    "Game",
    "Rent",
    "Entertainment",
  ];
  final List<String> _incomecategories = [
    "Salary",
    "Investment",
    "Comission",
    "Intrest",
    "Gift",
  ];

  List<String> get expensecategories => _expensecategories;
  List<String> get incomecategories => _incomecategories;
  String get expenseselectedcategory => _expenseselectedcategory;
  String get incomeselectedcategory => _incomeselectedcategory;

  void selectexpenseCategory(value) {
    _expenseselectedcategory = value;
    notifyListeners();
  }

  void selectincomeCategory(value) {
    _incomeselectedcategory = value;
    notifyListeners();
  }

  void isIncome(bool value) {
    _income = value;
    notifyListeners();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2060),
    );

    if (picked != null) {
      _selectedDate = picked.toString();
      notifyListeners();
    }
  }

  Future<void> addTransaction() async {
    try {
      final transactionData = TransactionModel(
        amount: _amountController.text,
        category: _expenseselectedcategory,
        date: _selectedDate,
        remarks: _descriptionController.text,
        expense: _income,
        title: _titleController.text,
        id: "",
      );

      final docRef = await _firebaseFirestore.add(transactionData.toMap());

      //For creation of updated model with id
      final updatedTransaction = transactionData.copyWith(id: docRef.id);
      _transactions.add(updatedTransaction);

      _titleController.clear();
      _amountController.clear();
      _descriptionController.clear();
      log(transactionData.amount);
      notifyListeners();
    } catch (e) {
      log("some error occurred $e");
    }
  }

  Future<TransactionModel> getSingleTransaction(String transactionId) async {
    try {
      final doc = await _firebaseFirestore.doc(transactionId).get();
      if (doc.exists) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      throw Exception('Transaction not found');
    } catch (e) {
      log("Error fetching transaction: $e");
      rethrow;
    }
  }

  Future<void> getTransactions() async {
    try {
      final snapshot = await _firebaseFirestore.get();
      _transactions = snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      log("Error $e");
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
