import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'language';
  static const String _userStateKey = 'user_state';
  Locale _locale = const Locale('en');

  LanguageService() {
    _loadSavedLanguage();
  }

  Locale get locale => _locale;

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    // Sauvegarder l'état actuel de l'utilisateur
    final prefs = await SharedPreferences.getInstance();
    final currentState = prefs.getString(_userStateKey);
    
    // Changer la langue
    _locale = Locale(languageCode);
    await prefs.setString(_languageKey, languageCode);
    
    // Restaurer l'état de l'utilisateur
    if (currentState != null) {
      await prefs.setString(_userStateKey, currentState);
    }
    
    notifyListeners();
  }

  bool isRTL() {
    return _locale.languageCode == 'ar';
  }
} 