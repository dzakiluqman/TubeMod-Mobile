import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/custom_bottom_navbar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Index 1 untuk halaman History
  final int _selectedIndex = 1;

  // Data Dummy untuk list history
  final List<Map<String, String>> _dummyHistory = [
    {
      "title": "Lorem ipsum dolor sit amet",
      "url": "https://www.youtube.com/watch?v=lorem",
      "date": "2026-02-25 10:30"
    },
    {
      "title": "Lorem ipsum dolor sit amet",
      "url": "https://www.youtube.com/watch?v=lorem",
      "date": "2026-02-25 10:30"
    },
    {
      "title": "Lorem ipsum dolor sit amet",
      "url": "https://www.youtube.com/watch?v=lorem",
      "date": "2026-02-25 10:30"
    },
    {
      "title": "Lorem ipsum dolor sit amet",
      "url": "https://www.youtube.com/watch?v=lorem",
      "date": "2026-02-25 10:30"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header (Sama persis dengan home_screen.dart)
              _buildHeader(),

              const SizedBox(height: 30),
              
              // Judul "History"
              Text(
                'History',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E004F),
                ),
              ),

              const SizedBox(height: 20),

              // List History
              _buildHistoryList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 1) return;

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/keywords');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
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
            Row(
              children: [
                Image.asset(
                  'assets/images/tubemod_text.png',
                  height: 28, 
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 30,
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

  // Widget List History Card
  Widget _buildHistoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _dummyHistory.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _dummyHistory[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF5A008A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['url']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Analyzed on: ${item['date']}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Logic hapus history
                  },
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Color(0xFFB37FEB), // Warna ikon sampah agak terang sesuai gambar
                    size: 26,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}