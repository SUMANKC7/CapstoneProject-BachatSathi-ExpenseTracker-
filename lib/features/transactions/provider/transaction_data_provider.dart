import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class TransactionDataProvider extends ChangeNotifier {
  // final amountController = TextEditingController();
  // final descriptionController = TextEditingController();
  // bool _income = false;
  // DateTime _date = DateTime.now();

  // DateTime get date => _date;
  // bool get income => _income;
  // String get formattedDate => DateFormat("yyyy/MM/dd").format(_date);

  // final List<String> _categories = [
  //   "Food",
  //   "Entertainment",
  //   "Shopping",
  //   "Transportation",
  //   "utilities",
  // ];

  // String _selectedcategory = "Category";

  // List<String> get categories => _categories;
  // String get selectedcategory => _selectedcategory;

  // void selectcategory(String category) {
  //   _selectedcategory = category;
  //   notifyListeners();
  // }

  // void switchExpense(value) {
  //   _income = value;
  //   notifyListeners();
  // }

  // Future<void> savetransation() async {
  //   try {
  //     final box = Hive.box<AddTransactionModel>("transactions");
  //     final mytransaction = AddTransactionModel(
  //       amount: amountController.text.trim(),
  //       category: _selectedcategory,
  //       date: date,
  //       description: descriptionController.text.trim(),
  //       income: _income, userId: '',
  //     );

  //     await box.add(mytransaction);
  //     debugPrint(
  //       '✅ Note saved: ${mytransaction.amount},${mytransaction.category} ${mytransaction.description}, ${mytransaction.date}',
  //     );

  //     clearAddTransactionForm();
  //   } catch (e) {
  //     debugPrint("Error occurred $e");
  //   }
  // }

  // void clearAddTransactionForm() {
  //   amountController.clear();
  //   descriptionController.clear();
  //   _selectedcategory = "Category";
  //   _date = DateTime.now();
  //   _income = false;
  //   notifyListeners();
  // }

  // @override
  // void dispose() {
  //   amountController.dispose();
  //   descriptionController.dispose();
  //   super.dispose();
  // }

  // final _amountController = TextEditingController();
  // final _descriptionController = TextEditingController();
  // bool _income = false;
  // final DateTime _dateTime = DateTime.now();

  // DateTime get dateTime => _dateTime;
  // String get formattedDate => DateFormat("yyyy/mm/dd").format(_dateTime);
  // TextEditingController get amountController => _amountController;
  // TextEditingController get descriptionController => _descriptionController;
  // bool get income => _income;

  // final List<String> _categories = [
  //   "Food",
  //   "Entertainment",
  //   "Shopping",
  //   "Transportation",
  //   "utilities",
  // ];
  // List<String> get categories => _categories;

  // String _selectedCategory = "Category";
  // String get selectedcategory => _selectedCategory;

  // final firebasefirestore = FirebaseFirestore.instance;

  // void selectcategory(String category) {
  //   _selectedCategory = category;
  //   notifyListeners();
  // }

  // void switchExpense(value) {
  //   _income = value;
  //   notifyListeners();
  // }

  // Future<void> addTransaction() async {
  //   try {
  //     final transactionData = TransactionModel(
  //       amount: _amountController.text,
  //       category: _selectedCategory,
  //       date: formattedDate,
  //       description: _descriptionController.text,
  //       expense: _income,
  //     );
  //     await firebasefirestore
  //         .collection("Transaction")
  //         .add(transactionData.toMap());

  //     //Clearing the data
  //     _amountController.clear();
  //     _descriptionController.clear();
  //     _selectedCategory = "Category";
  //     _income = false;

  //   } catch (e) {
  //     log("Error occurred :$e");
  //   }

  // }
  // @override
  // void dispose() {
  //      _amountController.dispose();
  //     _descriptionController.dispose();
  //   super.dispose();
  // }

  final firebaseFirestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _income = false;
  final DateTime _currentdate = DateTime.now();
  String _selectedcategory = "categories";
  
  TextEditingController get titleController => _titleController;
  TextEditingController get amountController => _amountController;
  TextEditingController get descriptionController => _descriptionController;

  String get formattedDate => DateFormat("yyyy/mm/dd").format(_currentdate);
  bool get income => _income;

  final List<String> _categories = ["Food", "Clothes", "Entertainment", "Game"];

  List<String> get categories => _categories;
  String get selectedCategory => _selectedcategory;

  void selectCategory(value) {
    _selectedcategory = value;
    notifyListeners();
  }

  void isIncome(bool value) {
    _income = value;
    notifyListeners();
  }

  Future<void> addTransaction() async {
    try {
      final transactionData = TransactionModel(
        amount: _amountController.text,
        category: _selectedcategory,
        date: formattedDate,
        description: _descriptionController.text,
        expense: _income,
        title: _titleController.text,
      );

      await firebaseFirestore
          .collection("Transactions")
          .doc("Transaction")
          .set(transactionData.toMap());
      log(transactionData.amount);
      notifyListeners();
    } catch (e) {
      log("some error occurred $e");
    }
  }
}
