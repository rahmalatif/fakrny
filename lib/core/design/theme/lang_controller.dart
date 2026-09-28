import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangController extends ChangeNotifier {
  static const String languageKey = 'selected_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLanguage = prefs.getString(languageKey);

    if (savedLanguage == 'ar' || savedLanguage == 'en') {
      _locale = Locale(savedLanguage!);
    }
  }

  Future<void> changeLocale(Locale locale) async {
    if (locale.languageCode != 'ar' && locale.languageCode != 'en') {
      return;
    }

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(languageKey, locale.languageCode);

    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');

    await changeLocale(newLocale);
  }
}
