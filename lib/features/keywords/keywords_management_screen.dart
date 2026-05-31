import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/widgets/custom_bottom_navbar.dart';

class KeywordsManagementScreen extends StatefulWidget {
  const KeywordsManagementScreen({Key? key}) : super(key: key);

  @override
  State<KeywordsManagementScreen> createState() =>
      _KeywordsManagementScreenState();
}

class _KeywordsManagementScreenState extends State<KeywordsManagementScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final List<Map<String, String>> _keywords = [
    {
      'keyword': 'judol',
      'category': 'spam',
    },
    {
      'keyword': 'slot gacor',
      'category': 'gambling',
    },
    {
      'keyword': 'bodoh',
      'category': 'hate',
    },
    {
      'keyword': 'anjing',
      'category': 'hate',
    },
    {
      'keyword': 'klik link ini',
      'category': 'spam',
    },
    {
      'keyword': 'scam',
      'category': 'fraud',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ================= HEADER =================
            _buildHeader(),

            const SizedBox(height: 24),

            // ================= TITLE =================
            Center(
              child: Text(
                'Keywords Management',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF4A007E),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= INPUT =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFF4A007E),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _keywordController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Keyword',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey.shade400,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _categoryController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Category',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A007E),
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: _addKeyword,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= KEYWORDS LIST =================
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF50007B),
                      Color(0xFF3B005A),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                ),
                child: ListView.builder(
                  itemCount: _keywords.length,
                  itemBuilder: (context, index) {
                    final keyword = _keywords[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          // Keyword
                          Expanded(
                            flex: 3,
                            child: Text(
                              keyword['keyword']!,
                              style: const TextStyle(
                                color: Color(0xFF4A007E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Divider
                          Container(
                            width: 1,
                            height: 18,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 12),

                          // Category
                          Expanded(
                            flex: 3,
                            child: Text(
                              keyword['category']!,
                              style: const TextStyle(
                                color: Color(0xFF4A007E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Edit Button
                          InkWell(
                            onTap: () => _editKeyword(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003B5C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.subject,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Delete Button
                          InkWell(
                            onTap: () => _deleteKeyword(index),
                            child: const Icon(
                              Icons.delete,
                              color: Color(0xFF8B0000),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/history');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushNamed(context, '/dashboard');
              break;
          }
        },
      ),
    );
  }

  // ================= HEADER =================
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

  // ================= ADD =================
  void _addKeyword() {
    if (_keywordController.text.isNotEmpty &&
        _categoryController.text.isNotEmpty) {
      setState(() {
        _keywords.add({
          'keyword': _keywordController.text,
          'category': _categoryController.text,
        });

        _keywordController.clear();
        _categoryController.clear();
      });
    }
  }

  // ================= EDIT =================
  void _editKeyword(int index) {
    _keywordController.text = _keywords[index]['keyword']!;
    _categoryController.text = _keywords[index]['category']!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Edit Keyword'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _keywordController.clear();
              _categoryController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _keywords[index] = {
                  'keyword': _keywordController.text,
                  'category': _categoryController.text,
                };

                _keywordController.clear();
                _categoryController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================
  void _deleteKeyword(int index) {
    setState(() {
      _keywords.removeAt(index);
    });
  }
}