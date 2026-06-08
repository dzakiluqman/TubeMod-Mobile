// lib/features/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/widgets/custom_header.dart';
import '../../core/data/keyword_repository.dart';
import '../../core/utils/session_manager.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  int _keywordCount = 0;
  int _historyCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Memuat data pengguna dari SessionManager dan data statistik dari API/Repository
  Future<void> _loadProfileData() async {
    final userData = SessionManager.instance.getUserData();
    int keywordCount = 0;
    int historyCount = 0;

    try {
      final keywordList = await ApiService.getKeywords();
      
      if (keywordList != null) {
        keywordCount = keywordList.length;
      } else {
        keywordCount = KeywordRepository.count;
      }
    } catch (e) {
      debugPrint('Error loading keyword count from API: $e');
      keywordCount = KeywordRepository.count;
    }

    try {
      // Mengambil total history dari pagination API
      final historyResult = await ApiService.getHistory(page: 1, limit: 1);
      if (historyResult != null && historyResult['pagination'] != null) {
        historyCount = historyResult['pagination']['total'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading history count: $e');
    }

    setState(() {
      _userData = userData;
      _keywordCount = keywordCount;
      _historyCount = historyCount;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? pictureUrl = _userData?['picture'] as String?;
    // Memecah nama dari email jika field nama tidak tersedia di database
    final String displayName = _userData?['name'] ?? 
        (_userData?['email'] != null ? _userData!['email'].split('@')[0] : 'User');

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // IMPLEMENTASI: CustomHeader disamakan persis dengan home_screen.dart
                const CustomHeader(
                  subtitle: 'One tool to manage\ntoxic comments\nin your YouTube\nchannels.',
                ),
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
                          child: CircleAvatar( 
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: const Color(0xFFE5E5EA),
                              backgroundImage: (pictureUrl != null && pictureUrl.isNotEmpty)
                                  ? NetworkImage(pictureUrl)
                                  : const AssetImage('assets/images/avatar.png') as ImageProvider,
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
                
                // Profile Info dinamis berdasarkan database/session
                Text(
                  displayName,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF4A007E),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'YouTube Channel Moderator',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A007E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '2026 Joined',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                
                const SizedBox(height: 35),
                _buildSectionTitle('SUMMARIZE'),
                
                // PERUBAHAN: Section SUMMARIZE kini berisi Keyword dan History Analysis
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    children: [
                      // Card Banned Keywords
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/keywords'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined, color: Color(0xFF4A007E)),
                              const SizedBox(width: 16),
                              Text(
                                '$_keywordCount Banned Keywords',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A007E),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF4A007E)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Card History Analysis
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/history'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.history_rounded, color: Color(0xFF4A007E)),
                              const SizedBox(width: 16),
                              Text(
                                '$_historyCount History Analysis',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4A007E),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF4A007E)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // PERUBAHAN: SUPPORT & CONTACT diubah menjadi INFORMATIONS
                _buildSectionTitle('INFORMATIONS'),
                
                // Card Informasi Akun (Email & Google ID) dari Database/Session
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A007E),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          Icons.email_outlined,
                          'Email Address',
                          _userData?['email'] ?? 'No Email Linked',
                        ),
                        _buildInfoTile(
                          Icons.fingerprint_rounded,
                          'Google ID',
                          _userData?['google_id'] ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                // Logout Button
                TextButton.icon(
                  onPressed: () async {
                    await SessionManager.instance.clearSession(); 

                    if (!context.mounted) return;

                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      '/home',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text(
                    'Logout', 
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}