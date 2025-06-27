import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class CrudProvider extends ChangeNotifier {
  final FirebaseFirestore _crudoperation = FirebaseFirestore.instance;

  Future<void> addDataToFirebase() async {
    await _crudoperation.collection("CashFlow").doc("name").set({});
  }
}
