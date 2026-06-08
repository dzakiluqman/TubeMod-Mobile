// lib/features/screens/keywords_management_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_style.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/widgets/custom_header.dart';
import '../../services/api_service.dart';

class KeywordsManagementScreen extends StatefulWidget {
  const KeywordsManagementScreen({Key? key}) : super(key: key);

  @override
  State<KeywordsManagementScreen> createState() =>
      _KeywordsManagementScreenState();
}

class _KeywordsManagementScreenState extends State<KeywordsManagementScreen> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool isLoading = true;
  bool isAdding = false;
  List<Map<String, dynamic>> keywords = [];

  // For edit mode
  int? editingKeywordId;

  @override
  void initState() {
    super.initState();
    _loadKeywords();
  }

  /// Load keywords dari API
  Future<void> _loadKeywords() async {
    try {
      setState(() => isLoading = true);

      final result = await ApiService.getKeywords();

      if (result != null) {
        setState(() {
          // Menyalin list dan mengurutkan berdasarkan ID terbesar di paling atas (data baru)
          keywords = List<Map<String, dynamic>>.from(result);
          keywords.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showErrorSnackBar('Failed to load keywords');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('ERROR: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Add new keyword
  Future<void> _addKeyword() async {
    if (_keywordController.text.isEmpty || _categoryController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    try {
      setState(() => isAdding = true);

      final success = await ApiService.addKeyword(
        word: _keywordController.text.trim(),
        category: _categoryController.text.trim(),
      );

      setState(() => isAdding = false);

      if (success) {
        _keywordController.clear();
        _categoryController.clear();
        _showSuccessSnackBar('Keyword added successfully');
        _loadKeywords(); // Refresh list akan otomatis menaruh yang baru di paling atas
      } else {
        _showErrorSnackBar('Failed to add keyword');
      }
    } catch (e) {
      setState(() => isAdding = false);
      debugPrint('ERROR ADD: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Update existing keyword
  Future<void> _updateKeyword() async {
    if (editingKeywordId == null ||
        _keywordController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    try {
      setState(() => isAdding = true);

      final success = await ApiService.updateKeyword(
        keywordId: editingKeywordId!,
        word: _keywordController.text.trim(),
        category: _categoryController.text.trim(),
      );

      setState(() => isAdding = false);

      if (success) {
        _keywordController.clear();
        _categoryController.clear();
        setState(() => editingKeywordId = null);
        _showSuccessSnackBar('Keyword updated successfully');
        _loadKeywords(); // Refresh list
      } else {
        _showErrorSnackBar('Failed to update keyword');
      }
    } catch (e) {
      setState(() => isAdding = false);
      debugPrint('ERROR UPDATE: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Delete keyword
  Future<void> _deleteKeyword(int keywordId) async {
    try {
      final confirmed = await _showConfirmDialog(
        'Delete this keyword?',
      );

      if (!confirmed) return;

      final success = await ApiService.deleteKeyword(keywordId);

      if (success) {
        setState(() {
          keywords.removeWhere((k) => k['id'] == keywordId);
        });
        _showSuccessSnackBar('Keyword deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete keyword');
      }
    } catch (e) {
      debugPrint('ERROR DELETE: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Prepare edit mode
  void _prepareEdit(Map<String, dynamic> keyword) {
    setState(() {
      editingKeywordId = keyword['id'];
      _keywordController.text = keyword['word'] ?? '';
      _categoryController.text = keyword['category'] ?? '';
    });

    // Show edit dialog
    _showEditDialog(keyword);
  }

  /// Show edit dialog
  void _showEditDialog(Map<String, dynamic> keyword) {
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
              setState(() => editingKeywordId = null);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateKeyword();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= IMPLEMENTASI CUSTOM HEADER =================
              const CustomHeader(
                subtitle: 'One tool to manage\ntoxic comments\nin your YouTube\nchannels.',
              ),

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
                          onTap: isAdding
                              ? null
                              : (editingKeywordId != null
                                  ? _updateKeyword
                                  : _addKeyword),
                          child: Icon(
                            editingKeywordId != null ? Icons.check : Icons.add,
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

              // ================= KEYWORDS LIST (CARD UTUH) =================
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20), // Disamakan paddingnya agar seimbang
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF50007B),
                      Color(0xFF3B005A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24), // Menggunakan circular agar menjadi 1 card utuh
                ),
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : keywords.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.key,
                                    size: 60,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No keywords yet',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first keyword',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: keywords.length,
                            itemBuilder: (context, index) {
                              final keyword = keywords[index];
                              final isEditing =
                                  editingKeywordId == keyword['id'];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isEditing
                                      ? Colors.yellow.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  border: isEditing
                                      ? Border.all(
                                          color: Colors.yellow.shade700,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            keyword['word'] ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF4A007E),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            keyword['category'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _prepareEdit(keyword),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF003B5C),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () =>
                                          _deleteKeyword(keyword['id']),
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

              // ================= SPACE DI BAWAH CARD =================
              const SizedBox(height: 40), // Memberikan jarak agar bagian bawah list tidak terpotong Navbar
            ],
          ),
        ),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 2) return;

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/history');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}