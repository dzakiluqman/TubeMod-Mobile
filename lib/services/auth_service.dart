// lib/services/auth_service.dart

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../core/utils/session_manager.dart';

class AuthService {
  // Backend configuration
  // IMPORTANT: Use PROXY endpoint instead of direct API endpoint
  // This bypasses the hosting-level WAF JavaScript challenge
  static const String baseUrl = 'https://tubemod.online';
  static const String proxyEndpoint = '/api/proxy.php'; // ← Server-side proxy
  
  // Direct API endpoints (for reference, but we use proxy)
  static const String loginEndpoint = '/api/auth/login';
  static const String refreshEndpoint = '/api/auth/refresh';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String meEndpoint = '/api/auth/me';

  // Google Sign-In configuration
  // IMPORTANT: Use WEB Client ID (not Android Client ID)
  static const String googleServerClientId =
      '914845598304-6i39d93d9f2p9n2mdj3uq5uvbpihkmtj.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  // Singleton
  static final AuthService _instance = AuthService._();

  AuthService._() {
    _initializeGoogleSignIn();
  }

  factory AuthService() {
    return _instance;
  }

  /// Initialize Google Sign-In
  void _initializeGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      serverClientId: googleServerClientId,
      scopes: [
        'email',
        'profile',
      ],
    );

    developer.log('[AuthService] GoogleSignIn initialized with serverClientId: $googleServerClientId');
  }

  /// Main login method - called from LoginPopup
  /// Returns true if successful, false otherwise
  Future<bool> loginWithGoogle() async {
    try {
      developer.log('[AuthService] Starting Google Sign-In flow');

      // Step 1: Sign in with Google
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser == null) {
        developer.log('[AuthService] Google Sign-In cancelled by user');
        return false;
      }

      developer.log('[AuthService] Google Sign-In successful for ${_currentUser!.email}');

      // Step 2: Get Google authentication tokens
      final googleAuth = await _currentUser!.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        developer.log('[AuthService] ERROR: Google ID Token is NULL');
        return false;
      }

      developer.log('[AuthService] Got Google ID Token: ${idToken.substring(0, 20)}...');
      developer.log('[AuthService] Got Google Access Token: ${accessToken?.substring(0, 20) ?? 'N/A'}...');

      // Step 3: Send to backend via PROXY endpoint
      final success = await _sendTokenToBackendViaProxy(
        idToken: idToken,
        accessToken: accessToken,
        email: _currentUser!.email,
        name: _currentUser!.displayName ?? 'User',
        picture: _currentUser!.photoUrl ?? '',
      );

      if (!success) {
        developer.log('[AuthService] Failed to authenticate with backend');
        return false;
      }

      developer.log('[AuthService] Login successful - JWT token stored');
      return true;

    } on PlatformException catch (e) {
      developer.log('[AuthService] PlatformException during Google Sign-In', error: e);
      return false;
    } catch (e) {
      developer.log('[AuthService] Unexpected error during login', error: e);
      return false;
    }
  }

  /// Send Google token to backend via SERVER-SIDE PROXY
  /// This bypasses the WAF JavaScript challenge
  /// 
  /// Flow:
  /// 1. Flutter sends token to /api/proxy.php with action="login"
  /// 2. proxy.php uses cURL to forward to /api/auth/login internally
  /// 3. cURL request bypasses WAF (server-to-server traffic)
  /// 4. Backend returns JWT token
  /// 5. proxy.php returns JWT to Flutter
  Future<bool> _sendTokenToBackendViaProxy({
    required String idToken,
    required String? accessToken,
    required String email,
    required String name,
    required String picture,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$proxyEndpoint');

      developer.log('[AuthService] Sending token via PROXY: $url');

      // Step 1: Prepare proxy request
      // The proxy accepts action + data format
      final proxyPayload = {
        'action': 'login', // Maps to /api/auth/login
        'data': {
          'id_token': idToken,
          'access_token': accessToken,
          'email': email,
          'name': name,
          'picture': picture,
        }
      };

      // Step 2: Send POST request to proxy
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'TubeMod-Flutter/1.0',
        },
        body: jsonEncode(proxyPayload),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Backend request timed out'),
      );

      developer.log('[AuthService] Proxy response code: ${response.statusCode}');

      // Step 3: Check for HTML response (WAF or error page)
      if (_isHtmlResponse(response.body)) {
        developer.log('[AuthService] ERROR: Proxy returned HTML instead of JSON');
        developer.log('[AuthService] Response body: ${response.body.substring(0, min(500, response.body.length))}');
        return false;
      }

      // Step 4: Parse JSON response from proxy
      final jsonResponse = _safeJsonDecode(response.body);
      if (jsonResponse == null) {
        developer.log('[AuthService] ERROR: Failed to parse JSON response');
        return false;
      }

      // Step 5: Check for success status
      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        final token = jsonResponse['data']?['token'];
        final userData = jsonResponse['data']?['user'];

        if (token == null || userData == null) {
          developer.log('[AuthService] ERROR: Missing token or user data in response');
          developer.log('[AuthService] Response: $jsonResponse');
          return false;
        }

        // Step 6: Save JWT token and user data locally
        await SessionManager.instance.saveToken(token);
        await SessionManager.instance.saveUserData(userData);

        developer.log('[AuthService] ✓ Login successful - JWT token saved');
        return true;
      } else {
        // Backend returned error
        final errorMsg = jsonResponse['message'] ?? 'Unknown error';
        developer.log('[AuthService] Backend error: $errorMsg');
        return false;
      }

    } on TimeoutException catch (e) {
      developer.log('[AuthService] Timeout error', error: e);
      return false;
    } on http.ClientException catch (e) {
      developer.log('[AuthService] Network error', error: e);
      return false;
    } catch (e) {
      developer.log('[AuthService] Unexpected error sending token', error: e);
      return false;
    }
  }

  /// Safely decode JSON with error handling
  Map<String, dynamic>? _safeJsonDecode(String jsonString) {
    try {
      if (jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('[AuthService] JSON decode error', error: e);
      return null;
    }
  }

  /// Detect if response is HTML instead of JSON
  bool _isHtmlResponse(String body) {
    if (body.isEmpty) return false;
    
    final trimmed = body.trim().toLowerCase();
    return trimmed.startsWith('<') ||
        trimmed.startsWith('<!') ||
        body.contains('<html') ||
        body.contains('<body') ||
        body.contains('<script') ||
        body.contains('<!doctype');
  }

  /// Make authenticated request to API via proxy
  /// Used for other endpoints (analyze, keyword, history, etc.)
  Future<http.Response> makeProxyRequest({
    required String action,
    required String method,
    Map<String, dynamic>? data,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$proxyEndpoint');

      final token = getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'TubeMod-Flutter/1.0',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final proxyPayload = {
        'action': action,
        'data': data ?? {},
        '_method': method,
      };

      developer.log('[AuthService] Making proxy request: action=$action, method=$method');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(proxyPayload),
      ).timeout(
        const Duration(seconds: 30),
      );

      return response;

    } catch (e) {
      developer.log('[AuthService] Error making proxy request', error: e);
      rethrow;
    }
  }

  /// Get stored JWT token
  String? getToken() {
    return SessionManager.instance.getToken();
  }

  /// Get stored user data
  Map<String, dynamic>? getUserData() {
    return SessionManager.instance.getUserData();
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return SessionManager.instance.isLoggedIn();
  }

  /// Get authorization header
  String? getAuthorizationHeader() {
    final token = getToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  /// Get headers for API requests (includes JWT)
  Map<String, String> getAuthHeaders() {
    return SessionManager.instance.getAuthHeaders();
  }

  /// Refresh JWT token (extend session)
  Future<bool> refreshToken() async {
    try {
      if (!isLoggedIn()) {
        developer.log('[AuthService] User not logged in, cannot refresh');
        return false;
      }

      developer.log('[AuthService] Refreshing token via proxy');

      final response = await makeProxyRequest(
        action: 'refresh',
        method: 'POST',
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        if (jsonResponse?['status'] == 'success') {
          final newToken = jsonResponse?['data']?['token'];
          if (newToken != null) {
            await SessionManager.instance.updateToken(newToken);
            developer.log('[AuthService] ✓ Token refreshed successfully');
            return true;
          }
        }
      }

      developer.log('[AuthService] Token refresh failed');
      return false;

    } catch (e) {
      developer.log('[AuthService] Error refreshing token', error: e);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      developer.log('[AuthService] Starting logout');

      // Call backend logout via proxy (optional)
      try {
        if (isLoggedIn()) {
          await makeProxyRequest(
            action: 'logout',
            method: 'POST',
          ).timeout(
            const Duration(seconds: 10),
          );
        }
      } catch (e) {
        developer.log('[AuthService] Backend logout failed (non-critical)', error: e);
      }

      // Clear local session
      await SessionManager.instance.clearSession();

      // Sign out from Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        developer.log('[AuthService] Google Sign-Out failed (non-critical)', error: e);
      }

      _currentUser = null;

      developer.log('[AuthService] ✓ Logout successful');

    } catch (e) {
      developer.log('[AuthService] Logout error', error: e);
    }
  }

  /// Check for existing login on app startup
  Future<bool> checkExistingLogin() async {
    try {
      if (!SessionManager.instance.isLoggedIn()) {
        return false;
      }

      // Try silent sign-in with Google
      _currentUser = await _googleSignIn.signInSilently();
      
      if (_currentUser != null) {
        developer.log('[AuthService] ✓ Silent sign-in successful');
        return true;
      }

      return false;

    } catch (e) {
      developer.log('[AuthService] Silent sign-in failed', error: e);
      return false;
    }
  }

  /// Get current Google user
  GoogleSignInAccount? get currentUser => _currentUser;
}

/// Helper function for string operations
int min(int a, int b) => a < b ? a : b;

/// Timeout exception
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}