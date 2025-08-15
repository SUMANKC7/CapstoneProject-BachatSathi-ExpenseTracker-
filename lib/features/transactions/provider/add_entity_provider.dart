import 'package:expensetrack/features/transactions/services/all_transaction_entity_service.dart';
import 'package:flutter/material.dart';

class AddTransactionProvider extends ChangeNotifier {
  final AddTransactionRepo repository;

  AddTransactionProvider(this.repository);

  bool isExpense = true; // true = expense, false = income

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void toggleTransactionType(bool value) {
    if (isExpense != value) {
      isExpense = value;
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateCtrl.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<bool> saveTransaction(
    BuildContext context, {
    required String title,
    required bool isExpense,
    required String remarks,
    required DateTime date,
    required String category,
    required double amount,
  }) async {
    try {
      print('Provider saveTransaction called with:');
      print('Title: $title');
      print('Amount: $amount');
      print('Category: $category');
      print('Date: $date');
      print('Remarks: $remarks');
      print('IsExpense: $isExpense');

      // Use the parameters passed from the UI, not the controllers
      await repository.addTransaction(
        title: title,
        amount: amount,
        category: category,
        date: date,
        remarks: remarks,
        expense: isExpense,
      );

      print('Repository addTransaction completed successfully');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );

      return true;
    } catch (e) {
      print('Error in provider saveTransaction: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      return false;
    }
  }

  // This method can be used for forms that use the provider's controllers
  Future<bool> saveTransactionFromControllers(BuildContext context) async {
    if (!validateForm()) return false;

    try {
      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
      final date = DateTime.tryParse(dateCtrl.text.trim()) ?? DateTime.now();

      await repository.addTransaction(
        title: titleCtrl.text.trim(),
        amount: amount,
        category: categoryCtrl.text.trim(),
        date: date,
        remarks: remarksCtrl.text.trim(),
        expense: isExpense,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully')),
      );

      clearForm();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      return false;
    }
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void clearForm() {
    titleCtrl.clear();
    amountCtrl.clear();
    categoryCtrl.clear();
    dateCtrl.clear();
    remarksCtrl.clear();
    isExpense = true;
    notifyListeners();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    categoryCtrl.dispose();
    dateCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }
}
