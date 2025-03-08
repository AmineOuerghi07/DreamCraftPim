// model/services/UserPreferences.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:pim_project/model/domain/user.dart';

class UserPreferences {
  static const String _userIdKey = 'userId';
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _rememberMeKey = 'rememberMe';

  // Save userId
  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get userId
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save user object
  static Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  // Get user object
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Save remember me preference
  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  // Get remember me preference
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  // Clear all stored data (e.g., on logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rememberMeKey);
  }
}