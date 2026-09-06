import 'package:flutter/material.dart';

class LangController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }

    notifyListeners();
  }

  void changeLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}