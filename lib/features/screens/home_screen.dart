// lib/features/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/widgets/custom_header.dart';
import '../../core/widgets/login_popup.dart';
import '../../core/utils/session_manager.dart';
import '../analyze/analysis_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();

      // DEBUG: Print user data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SessionManager.instance.debugPrintSession();
        final userData = SessionManager.instance.getUserData();
        print('=== WEB/MOBILE USER DATA ===');
        print('User ID: ${userData?['id']}');
        print('Email: ${userData?['email']}');
        print('Google ID: ${userData?['google_id']}');
        print('Token: ${userData?['token']}');
        print('============================');
      });
    });
  }

  void _checkLoginStatus() {
    final isLoggedIn = SessionManager.instance.isLoggedIn();
    if (!isLoggedIn) {
      LoginPopup.show(context);
    } else {
      SessionManager.instance.debugPrintSession();
    }
  }

  String extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v']!;
      }
      if (uri.pathSegments.contains('shorts')) {
        return uri.pathSegments.last;
      }
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.first;
      }
      return '';
    } catch (e) {
      print('Error extracting video ID: $e');
      return '';
    }
  }

  void _handleAnalyze() {
    final videoId = extractVideoId(_urlController.text);

    if (videoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid YouTube URL'),
          backgroundColor: Color(0xFFFF4444),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(videoId: videoId),
      ),
    );
  }

  void _handleNavigation(int index) {
    if (index == 0) return;

    switch (index) {
      case 1:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/keywords');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // MENGGUNAKAN CUSTOM HEADER BARU DI SINI
              const CustomHeader(
                subtitle: 'One tool to manage\ntoxic comments\nin your YouTube\nchannels.',
              ),
              _buildInputSection(),
              const SizedBox(height: 10),
              _buildFeatureSection(),
              const SizedBox(height: 20),
              _buildCTABanner(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF5A008A),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'Insert a YouTube video URL',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleAnalyze,
            child: Container(
              width: 84,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF5A008A),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection() {
    return SizedBox(
      height: 170,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        children: [
          _featureCard(
            "Smart\nDetection",
            "assets/images/smart_detection.png",
          ),
          const SizedBox(width: 14),
          _featureCard(
            "Bulk\nCleanup",
            "assets/images/bulk_cleanup.png",
          ),
          const SizedBox(width: 14),
          _featureCard(
            "History\nAnalytics",
            "assets/images/history_analytics.png",
          ),
        ],
      ),
    );
  }

  Widget _featureCard(String title, String image) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              image,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x88000000),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTABanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF5A008A),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Discover the full scale of TubeMod capabilities",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "Start now",
                style: TextStyle(
                  color: Color(0xFF5A008A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem("2026", "TubeMod\nFounded"),
          _buildStatItem("1k+", "Active\nUsers"),
          _buildStatItem("10+", "Creators\nTrust"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5A008A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF5A008A),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}