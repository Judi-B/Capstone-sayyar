// lib/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'jwt_token';
  static const _username = 'first_name';
  static const _isSubscribed = 'is_subscribed';
  static const _subscribedCompany = 'subscribed_company';


  // Save token
  static Future<void> saveToken(token, name, isSubscribed, subscribedCompany) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_username, name);
    await prefs.setBool(_isSubscribed, isSubscribed == null? false: isSubscribed);
    await prefs.setString(_subscribedCompany, subscribedCompany == null? '': subscribedCompany);
  }

  // Read token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_username);
    await prefs.remove(_isSubscribed);
    await prefs.remove(_subscribedCompany);
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool?> isSubscribed() async {
    final prefs = await SharedPreferences.getInstance();
     return prefs.getBool(_isSubscribed);
  }
}
