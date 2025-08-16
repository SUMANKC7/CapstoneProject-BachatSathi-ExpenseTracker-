import 'package:expensetrack/features/transactions/model/transaction_model.dart';
import 'package:expensetrack/features/transactions/services/all_transaction_entity_service.dart';
import 'package:flutter/material.dart';

class AddTransactionProvider extends ChangeNotifier {
  final AddTransactionRepo repository;

  AddTransactionProvider(this.repository);

  bool isExpense = true; // true = expense, false = income
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;

  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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
      _setLoading(true);
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

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      print('Error in provider saveTransaction: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      return false;
    }
  }

  /// Update an existing transaction
  Future<bool> updateTransaction(
    BuildContext context, {
    required String transactionId,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required String remarks,
    required bool isExpense,
  }) async {
    try {
      _setLoading(true);

      print('Provider updateTransaction called with:');
      print('ID: $transactionId');
      print('Title: $title');
      print('Amount: $amount');
      print('Category: $category');
      print('Date: $date');
      print('Remarks: $remarks');
      print('IsExpense: $isExpense');

      // Prepare update data
      final updateData = {
        'title': title,
        'amount': amount,
        'category': category.isEmpty ? 'General' : category,
        'date': date,
        'remarks': remarks,
        'expense': isExpense,
      };

      await repository.updateTransaction(transactionId, updateData);

      print('Repository updateTransaction completed successfully');

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      print('Error in provider updateTransaction: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(
    BuildContext context, {
    required String transactionId,
  }) async {
    try {
      _setLoading(true);

      print('Provider deleteTransaction called with ID: $transactionId');

      await repository.deleteTransaction(transactionId);

      print('Repository deleteTransaction completed successfully');

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      print('Error in provider deleteTransaction: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Get a single transaction by ID
  Future<AllTransactionModel?> getTransactionById(String transactionId) async {
    try {
      return await repository.getTransactionById(transactionId);
    } catch (e) {
      print('Error getting transaction by ID: $e');
      return null;
    }
  }

  // This method can be used for forms that use the provider's controllers
  Future<bool> saveTransactionFromControllers(BuildContext context) async {
    if (!validateForm()) return false;

    try {
      _setLoading(true);
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
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
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
