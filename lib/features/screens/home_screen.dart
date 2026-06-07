// lib/features/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
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

    // Check if user is logged in after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  /// Check if user is logged in, show LoginPopup if not
  void _checkLoginStatus() {
    final isLoggedIn = SessionManager.instance.isLoggedIn();

    if (!isLoggedIn) {
      // Show login popup if user is not logged in
      LoginPopup.show(context);
    } else {
      // Optional: Debug print when user is already logged in
      SessionManager.instance.debugPrintSession();
    }
  }

  /// Extract video ID from YouTube URL
  String extractVideoId(String url) {
    try {
      final uri = Uri.parse(url);

      // Format: youtube.com/watch?v=VIDEO_ID
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v']!;
      }

      // Format: youtube.com/shorts/VIDEO_ID
      if (uri.pathSegments.contains('shorts')) {
        return uri.pathSegments.last;
      }

      // Format: youtu.be/VIDEO_ID
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.first;
      }

      return '';
    } catch (e) {
      print('Error extracting video ID: $e');
      return '';
    }
  }

  /// Handle analyze button press
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

    // Navigate to analysis screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisResultScreen(videoId: videoId),
      ),
    );
  }

  /// Handle bottom navigation
  void _handleNavigation(int index) {
    if (index == 0) return; // Already on home

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
              _buildHeader(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 22, 30, 40),
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
                  // Show menu (logout, etc.)
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
          const SizedBox(height: 55),
          const SizedBox(
            width: 270,
            child: Text(
              'One tool to manage\ntoxic comments\nin your YouTube\nchannels.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
        ],
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

  /// Show menu (logout, settings, etc.)
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
            // User info
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

            // Logout button
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet
                _handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Handle logout
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
              Navigator.pop(context); // Close dialog

              // Clear session
              await SessionManager.instance.clearSession();

              // Show message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have been logged out'),
                  backgroundColor: Colors.orange,
                ),
              );

              // Show login popup again
              if (mounted) {
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