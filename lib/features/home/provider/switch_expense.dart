import 'package:flutter/material.dart';

class SwitchExpenseProvider extends ChangeNotifier {
  int selectedIndex = 0;
  int expenseSelectedIndex = 0;

  void toggleIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void toggleExpense(int index) {
    expenseSelectedIndex = index;
    notifyListeners();
  }
}
