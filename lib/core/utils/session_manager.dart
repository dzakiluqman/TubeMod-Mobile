// lib/core/utils/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionManager {
  // Storage keys
  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Singleton instance
  static final SessionManager _instance = SessionManager._();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  SessionManager._();

  static SessionManager get instance => _instance;

  /// Initialize SharedPreferences (call once in main.dart)
  Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;

    print('SessionManager initialized');
  }

  /// Save JWT token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
    print('Token saved: $token');
  }

  /// Get stored JWT token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Save user data as JSON
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, jsonEncode(userData));
    await _prefs.setBool(_isLoggedInKey, true);
    print('User data saved');
  }

  /// Get stored user data
  Map<String, dynamic>? getUserData() {
    final userDataJson = _prefs.getString(_userDataKey);
    if (userDataJson == null) return null;

    try {
      return jsonDecode(userDataJson) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get user email
  String? getUserEmail() {
    final userData = getUserData();
    return userData?['email'] as String?;
  }

  /// Get user name
  String? getUserName() {
    final userData = getUserData();
    return userData?['name'] as String?;
  }

  /// Get user profile picture
  String? getUserPicture() {
    final userData = getUserData();
    return userData?['picture'] as String?;
  }

  /// Get user ID
  int? getUserId() {
    final userData = getUserData();
    return userData?['id'] as int?;
  }

  /// Get authorization headers for API requests
  Map<String, String> getAuthHeaders() {
    final token = getToken();
    if (token == null || token.isEmpty) {
      return {'Content-Type': 'application/json'};
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Clear all session data (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userDataKey);
    await _prefs.setBool(_isLoggedInKey, false);

    print('Session cleared');
  }

  /// Update token only (for refresh operations)
  Future<void> updateToken(String newToken) async {
    await _prefs.setString(_tokenKey, newToken);
    print('Token updated');
  }

  /// Check if token exists and is valid
  bool hasValidToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get all session data (for debugging)
  Map<String, dynamic> getAllSessionData() {
    return {
      'token': getToken(),
      'userData': getUserData(),
      'isLoggedIn': isLoggedIn(),
      'email': getUserEmail(),
      'name': getUserName(),
    };
  }

  /// Debug: Print all session data
  void debugPrintSession() {
    print('=== SESSION DEBUG ===');
    print('IsLoggedIn: ${isLoggedIn()}');
    print('Token: ${getToken()}');
    print('Email: ${getUserEmail()}');
    print('Name: ${getUserName()}');
    print('UserID: ${getUserId()}');
    print('====================');
  }
}