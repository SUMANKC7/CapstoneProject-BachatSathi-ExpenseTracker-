import 'package:expensetrack/features/transactions/services/add_entity_services.dart';
import 'package:flutter/material.dart';

class AddEntityProvider extends ChangeNotifier {
  final EntityRepository repository;

  AddEntityProvider(this.repository);

  bool isCreditInfoSelected = true;
  bool toReceive = true;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final openingCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void toggleCreditInfo(bool value) {
    if (isCreditInfoSelected != value) {
      isCreditInfoSelected = value;
      notifyListeners();
    }
  }

  void toggleReceiveGive(bool value) {
    if (toReceive != value) {
      toReceive = value;
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

  Future<bool> saveEntity(BuildContext context) async {
    if (!validateForm()) return false;

    try {
      await repository.addEntity(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        openingBalance: openingCtrl.text.trim(),
        date: dateCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        isCreditInfoSelected: isCreditInfoSelected,
        toReceive: toReceive,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entity saved successfully')),
      );

      clearForm();
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving entity: $e')));
      return false;
    }
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void clearForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    openingCtrl.clear();
    dateCtrl.clear();
    emailCtrl.clear();
    addressCtrl.clear();
    isCreditInfoSelected = true;
    toReceive = true;
    notifyListeners();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    openingCtrl.dispose();
    dateCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }
}
