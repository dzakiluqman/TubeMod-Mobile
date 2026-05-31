import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> loginWithGoogle() async {
    try {
      // Simulasi loading login
      await Future.delayed(const Duration(seconds: 1));

      // Token dummy untuk kebutuhan demo
      const String dummyToken =
          'demo_token_tubemod_2026_static_login';

      // Simpan token seperti login asli
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'jwt_token',
        dummyToken,
      );

      // Optional data user demo
      await prefs.setString(
        'user_name',
        'Demo User',
      );

      await prefs.setString(
        'user_email',
        'demo@tubemod.com',
      );

      return true;
    } catch (e) {
      print('Demo login error: $e');
      return false;
    }
  }
}