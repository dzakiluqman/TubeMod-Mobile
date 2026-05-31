import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_style.dart';
import '../../services/auth_service.dart'; 

class LoginPopup extends StatefulWidget {
  const LoginPopup({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User tidak bisa asal klik luar untuk close saat proses
      builder: (context) => const LoginPopup(),
    );
  }

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.loginWithGoogle();

    if (!mounted) return; // Mencegah error jika widget sudah di-close duluan

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context); // Tutup popup jika sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Berhasil! Token tersimpan.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal login, silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _isLoading ? null : () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: _isLoading ? Colors.grey : AppColors.iconWhite,
                  size: 20,
                ),
              ),
            ),
            
            const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'You need to login with Google to manage\ncomments and keywords.',
              style: AppTextStyle.cardSubtitle.copyWith(
                fontSize: 14,
                color: AppColors.textWhite.withOpacity(0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
            
            const SizedBox(height: 24),
            
            // Google Sign In Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: _isLoading ? null : _handleGoogleLogin,
                  child: Center(
                    child: _isLoading 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryPurple,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                              width: 24,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.g_mobiledata, color: Colors.blue, size: 32),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: AppTextStyle.button.copyWith(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}