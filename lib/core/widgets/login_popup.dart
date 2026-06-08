// lib/core/widgets/login_popup.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_style.dart';
import '../../services/auth_service.dart';
import '../utils/session_manager.dart';

class LoginPopup extends StatefulWidget {
  const LoginPopup({Key? key}) : super(key: key);

  /// Show login popup dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during login
      builder: (context) => const LoginPopup(),
    );
  }

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  /// Handle Google login button press
  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // --- TAMBAHKAN PRINT INI ---
      print('====== [UI] TOMBOL GOOGLE DIKLIK ======'); 
      
      // Call AuthService to handle Google Sign-In
      final success = await _authService.loginWithGoogle();
      
      // --- TAMBAHKAN PRINT INI ---
      print('====== [UI] HASIL FUNGSI LOGIN: $success ======');

      if (!mounted) return; // Safety check

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Get user data for greeting
        final userName = SessionManager.instance.getUserName() ?? 'User';

        // Close popup automatically
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, $userName!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Show error message
        setState(() {
          _errorMessage =
              'Login failed. Please check your connection and try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // --- TAMBAHKAN PRINT INI ---
      print('====== [UI] ERROR CATCH TERPICU: $e ======');
      
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
            // Close Button (only visible if not loading)
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

            // Title
            const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Sign in with Google to manage comments and create custom keyword lists.',
              style: AppTextStyle.cardSubtitle.copyWith(
                fontSize: 14,
                color: AppColors.textWhite.withOpacity(0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),

            const SizedBox(height: 24),

            // Error message (if any)
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[900]?.withOpacity(0.3),
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                              // Google logo image
                              Image.asset(
                                'assets/images/google_logo.png',
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.blue,
                                  size: 32,
                                ),
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

            const SizedBox(height: 12),

            // Info text
            Text(
              'Your data is encrypted and secure',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textWhite.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}