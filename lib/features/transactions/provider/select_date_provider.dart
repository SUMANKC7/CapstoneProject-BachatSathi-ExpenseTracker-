
import 'package:flutter/material.dart';

class SelectDateProvider extends ChangeNotifier {
  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;



  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _selectedDate = picked;
      notifyListeners();
    }
  }
}
