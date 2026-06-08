import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/utils/session_manager.dart';

class AuthService {
  static const String baseUrl = 'https://1176-27-124-95-122.ngrok-free.app/TUBEMOD-NGROK';
  static const String loginEndpoint = '/apiauth/login';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '914845598304-6i39d93d9f2p9n2mdj3uq5uvbpihkmtj.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<bool> loginWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) return false;

      final auth = await user.authentication;
      final url = Uri.parse('$baseUrl$loginEndpoint');
      
      print('====== [LOGIN] Starting Google Sign In ======');
      print('Email: ${user.email}');
      print('ID Token: ${auth.idToken?.substring(0, 50)}...');
      print('Access Token: ${auth.accessToken?.substring(0, 50)}...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode({
          'id_token': auth.idToken,
          'access_token': auth.accessToken, // ← PENTING: Untuk delete comments
          'email': user.email,
          'name': user.displayName,
          'picture': user.photoUrl,
        }),
      ).timeout(const Duration(seconds: 40));

      print('====== [DEBUG] Login Response: ${response.statusCode} ======');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'success') {
          final token = json['data']['token'];
          Map<String, dynamic> userData = Map<String, dynamic>.from(json['data']['user']);
          userData['access_token'] = auth.accessToken;
          
          print('====== [SUCCESS] Login Successful ======');
          print('User ID: ${userData['id']}');
          print('Email: ${userData['email']}');
          print('Access Token Stored: ${userData['access_token'] != null}');
          
          // Save ke SessionManager
          await SessionManager.instance.saveToken(token);
          await SessionManager.instance.saveUserData(userData);
          
          return true;
        } else {
          print('====== [ERROR] ${json['message']} ======');
        }
      } else {
        print('====== [ERROR] Status Code: ${response.statusCode} ======');
      }
      
      return false;
    } catch (e) {
      print('====== [ERROR] Login Exception: $e ======');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      print('====== [LOGOUT] Logging out... ======');
      
      await _googleSignIn.signOut();
      await SessionManager.instance.clearSession();
      
      print('====== [SUCCESS] Logout Successful ======');
    } catch (e) {
      print('====== [ERROR] Logout failed: $e ======');
    }
  }

  /// Check if user is already signed in
  Future<bool> isSignedIn() async {
    final isSignedIn = await _googleSignIn.isSignedIn();
    final hasToken = SessionManager.instance.hasValidToken();
    
    return isSignedIn && hasToken;
  }
}