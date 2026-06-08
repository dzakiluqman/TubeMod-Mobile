// lib/core/utils/session_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionManager {
  // Storage keys
  static const String _tokenKey = 'jwt_token';
  static const String _youtubeTokenKey = 'youtube_access_token';
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

  // ==================== JWT TOKEN METHODS ====================

  /// Save JWT token (for app authentication)
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
    print('JWT Token saved');
  }

  /// Get stored JWT token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  // ==================== USER DATA METHODS ====================

  /// Save user data as JSON
  /// UserData should contain: {id, email, name, picture, access_token, ...}
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, jsonEncode(userData));
    await _prefs.setBool(_isLoggedInKey, true);
    
    // ✨ BARU: Extract dan simpan YouTube token dari userData
    final youtubeToken = userData['access_token'] as String?;
    if (youtubeToken != null && youtubeToken.isNotEmpty) {
      await saveYoutubeToken(youtubeToken);
      print('YouTube Token extracted and saved');
    }
    
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

  // ==================== YOUTUBE TOKEN METHODS (NEW) ==================== 

  /// ✨ BARU: Save YouTube OAuth access token
  /// This is extracted from userData['access_token'] during login
  Future<void> saveYoutubeToken(String token) async {
    await _prefs.setString(_youtubeTokenKey, token);
    print('YouTube token saved');
  }

  /// ✨ BARU: Get stored YouTube OAuth access token
  String? getYoutubeToken() {
    return _prefs.getString(_youtubeTokenKey);
  }

  // ==================== LOGIN STATUS METHODS ====================

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Check if token exists and is valid
  bool hasValidToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== USER INFO METHODS ====================

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
    final id = userData?['id'];
    
    // Handle both int and string types
    if (id is int) {
      return id;
    } else if (id is String) {
      return int.tryParse(id);
    }
    return null;
  }

  // ==================== AUTH HEADERS (UPDATED) ====================

  /// Get authorization headers for API requests
  /// 
  /// Returns:
  /// - Content-Type: application/json
  /// - Authorization: Bearer <JWT_TOKEN> (for app authentication)
  /// - X-YouTube-Token: <YOUTUBE_TOKEN> (for YouTube API operations)
  Map<String, String> getAuthHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add JWT token if available
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // ✨ BARU: Add YouTube token if available
    final youtubeToken = getYoutubeToken();
    if (youtubeToken != null && youtubeToken.isNotEmpty) {
      headers['X-YouTube-Token'] = youtubeToken;
    }

    return headers;
  }

  // ==================== LOGOUT (UPDATED) ====================

  /// Clear all session data (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_youtubeTokenKey);
    await _prefs.remove(_userDataKey);
    await _prefs.setBool(_isLoggedInKey, false);

    print('Session cleared');
  }

  // ==================== HELPER METHODS ====================

  /// Update token only (for refresh operations)
  Future<void> updateToken(String newToken) async {
    await _prefs.setString(_tokenKey, newToken);
    print('Token updated');
  }

  /// Get all session data (for debugging)
  Map<String, dynamic> getAllSessionData() {
    return {
      'token': getToken(),
      'youtubeToken': getYoutubeToken(),
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
    print('JWT Token: ${getToken() != null ? 'AVAILABLE' : 'NULL'}');
    print('YouTube Token: ${getYoutubeToken() != null ? 'AVAILABLE' : 'NULL'}');
    print('Email: ${getUserEmail()}');
    print('Name: ${getUserName()}');
    print('UserID: ${getUserId()}');
    print('====================');
  }
}