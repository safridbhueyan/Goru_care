import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  bool _isEnglish = false;
  bool get isEnglish => _isEnglish;

  void toggle() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }
}
