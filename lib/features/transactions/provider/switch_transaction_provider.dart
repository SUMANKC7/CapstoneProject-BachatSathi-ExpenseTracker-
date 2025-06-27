import 'package:flutter/cupertino.dart';

class SwitchTransactionProvider extends ChangeNotifier {
  bool _isSwitched = false;

  bool get isSwitched => _isSwitched;

  void switchButton(value) {
    _isSwitched = value;
    notifyListeners();
  }
}
