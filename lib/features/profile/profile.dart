import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/data/keyword_repository.dart';

class ProfileScreen extends StatefulWidget {
  // Perbaikan: Menggunakan super parameter
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _keywordCount = 0;

  @override
  void initState() {
    super.initState();
    _loadKeywordCount();
  }

  void _loadKeywordCount() {
    setState(() {
      _keywordCount = KeywordRepository.count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(),
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A007E),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Color(0xFFE5E5EA),
                              backgroundImage: AssetImage('assets/images/avatar.png'),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF007AFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 65),
                // Profile Info
                Text('Atta Halilintar', style: GoogleFonts.montserrat(color: const Color(0xFF4A007E), fontSize: 32, fontWeight: FontWeight.w800)),
                Text('Content Creator & Youtuber', style: GoogleFonts.montserrat(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF4A007E), borderRadius: BorderRadius.circular(12)),
                  child: Text('2026 Joined', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
                
                const SizedBox(height: 35),
                _buildSectionTitle('SUMMARIZE'),
                
                // Summarize Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/keywords'), // Perbaikan: Diletakkan di InkWell
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFF4A007E)),
                          const SizedBox(width: 16),
                          Text('$_keywordCount Banned Keywords', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: const Color(0xFF4A007E))),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF4A007E)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                _buildSectionTitle('SUPPORT & CONTACT'),
                
                // Support Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF4A007E), borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        _buildContactTile(Icons.email_outlined, 'Email', 'attahalilintar@gmail.com'),
                        _buildContactTile(Icons.phone_android_rounded, 'Phone', '+62 090 9090 9090'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                // Logout Button
                TextButton.icon(
                  onPressed: () {}, // Perbaikan: Menambahkan onPressed yang kosong
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Keluar Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          switch (index) {
            case 0: Navigator.pushReplacementNamed(context, '/home'); break;
            case 1: Navigator.pushReplacementNamed(context, '/history'); break;
            case 2: Navigator.pushReplacementNamed(context, '/keywords'); break;
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 22, 30, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6500A3), Color(0xFF50007B)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/tubemod_text.png', height: 28),
              const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
            ],
          ),
          const SizedBox(height: 55),
          const SizedBox(
            width: 270,
            child: Text('One tool to manage\ntoxic comments\nin your YouTube\nchannels.', 
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.15)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: GoogleFonts.montserrat(color: Colors.grey.shade700, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}