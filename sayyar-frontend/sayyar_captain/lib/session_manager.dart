// lib/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'jwt_token';
  static const username = 'first_name';


  // Save token
  static Future<void> saveToken(String token, name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(username, name);
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
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
