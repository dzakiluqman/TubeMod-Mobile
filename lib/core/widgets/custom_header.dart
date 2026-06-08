// lib/core/widgets/custom_header.dart

import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import 'login_popup.dart';

class CustomHeader extends StatefulWidget {
  final String? subtitle; // Menggunakan parameter opsional agar fleksibel di page lain

  const CustomHeader({
    Key? key,
    this.subtitle,
  }) : super(key: key);

  @override
  State<CustomHeader> createState() => _CustomHeaderState();
}

class _CustomHeaderState extends State<CustomHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        30, 
        22, 
        30, 
        widget.subtitle != null ? 40 : 22, // Menyesuaikan padding bawah jika tidak ada subtitle
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6500A3),
            Color(0xFF50007B),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/tubemod_text.png',
                height: 28,
                fit: BoxFit.contain,
              ),
              GestureDetector(
                onTap: () {
                  _showMenu();
                },
                child: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          // Jika subtitle diisi, tampilkan teks deskripsinya
          if (widget.subtitle != null) ...[
            const SizedBox(height: 55),
            SizedBox(
              width: 270,
              child: Text(
                widget.subtitle!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Menampilkan menu Bottom Sheet (Logout & info user)
  void _showMenu() {
    final userName = SessionManager.instance.getUserName() ?? 'User';
    final userEmail = SessionManager.instance.getUserEmail() ?? 'user@example.com';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF5A008A),
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Menangani konfirmasi dan proses log out
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog

              await SessionManager.instance.clearSession();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You have been logged out'),
                    backgroundColor: Colors.orange,
                  ),
                );

                // Kembalikan ke halaman login popup
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  LoginPopup.show(context);
                });
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}