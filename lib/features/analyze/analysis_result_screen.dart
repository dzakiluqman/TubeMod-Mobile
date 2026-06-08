import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/widgets/login_popup.dart';
import '../../core/utils/session_manager.dart';
import '../../services/api_service.dart';

class AnalysisResultScreen extends StatefulWidget {
  final String videoId;
  const AnalysisResultScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;
  bool isDeleting = false;
  
  List<Map<String, dynamic>> allComments = [];
  Map<String, dynamic>? analysisData;

  @override
  void initState() {
    super.initState();
    _analyzeVideo();
  }

  Future<void> _analyzeVideo() async {
    try {
      setState(() => isLoading = true);

      final result = await ApiService.analyzeVideo(
        youtubeUrl: 'https://www.youtube.com/watch?v=${widget.videoId}',
        applyFontFilter: true,
      );

      if (result != null) {
        setState(() {
          analysisData = result;
          allComments = List<Map<String, dynamic>>.from(result['comments'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showErrorSnackBar('Failed to analyze video');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('ERROR: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _handleDelete(String commentId) async {
    try {
      final success = await ApiService.deleteComment(
        commentId: commentId,
      );

      if (success) {
        setState(() {
          allComments.removeWhere((c) => c['id'] == commentId);
        });
        _showSuccessSnackBar('Comment deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete comment');
      }
    } catch (e) {
      debugPrint('ERROR DELETE: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _handleDeleteAll() async {
    try {
      final toxicComments = allComments
          .where((c) => c['is_toxic'] == true)
          .toList();

      if (toxicComments.isEmpty) {
        _showErrorSnackBar('No toxic comments to delete');
        return;
      }

      final confirmed = await _showConfirmDialog(
        'Delete ${toxicComments.length} toxic comments?',
      );

      if (!confirmed) return;

      setState(() => isDeleting = true);

      final result = await ApiService.deleteAllComments(
        comments: toxicComments,
        videoId: analysisData?['video_id'] ?? '',
        videoTitle: analysisData?['video_title'] ?? '',
        totalComments: analysisData?['total_comments'] ?? 0,
      );

      setState(() => isDeleting = false);

      if (result != null) {
        setState(() {
          allComments.removeWhere((c) => c['is_toxic'] == true);
        });

        final deletedCount = result['deleted_count'] ?? 0;
        final hiddenCount = result['hidden_count'] ?? 0;
        final message = result['message'] ??
            'Deleted $deletedCount comments${hiddenCount > 0 ? ' and hidden $hiddenCount' : ''}';

        _showSuccessSnackBar(message);
      } else {
        _showErrorSnackBar('Failed to delete toxic comments');
      }
    } catch (e) {
      setState(() => isDeleting = false);
      debugPrint('ERROR DELETE ALL: $e');
      _showErrorSnackBar('Error: $e');
    }
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
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

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
              Navigator.pop(context);
              await SessionManager.instance.clearSession();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You have been logged out'),
                  backgroundColor: Colors.orange,
                ),
              );

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

  @override
  Widget build(BuildContext context) {
    final displayList = allComments;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER DENGAN LOGO ASSET & BURGER MENU
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 22, 30, 35),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6500A3), Color(0xFF50007B)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BARIS 1: Logo tubemod asset dari HomeScreen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/tubemod_text.png',
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                      GestureDetector(
                        onTap: _showMenu,
                        child: const Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // BARIS 2: Judul Halaman
                  const Text(
                    'Analysis Result',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  
                  // Detail Informasi Video jika data sudah di-load
                  if (analysisData != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      analysisData?['video_title'] ?? 'Unknown Video',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${analysisData?['total_comments'] ?? 0} | Toxic: ${analysisData?['toxic_comments_count'] ?? 0}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // List Komentar
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6500A3),
                        ),
                      ),
                    )
                  : displayList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Colors.green.shade300,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No toxic comments found!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final comment = displayList[index];
                            final isToxic = comment['is_toxic'] ?? false;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isToxic ? Colors.red.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: isToxic
                                    ? Border.all(
                                        color: Colors.red.shade200,
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                title: Text(
                                  comment['author'] ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      comment['text'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isToxic) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              comment['category'] ?? 'Toxic',
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (comment['matched_keyword'] != null &&
                                              comment['matched_keyword']
                                                  .toString()
                                                  .isNotEmpty)
                                            Expanded(
                                              child: Text(
                                                'Match: ${comment['matched_keyword']}',
                                                style: TextStyle(
                                                  color: Colors.red.shade600,
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: isToxic
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _handleDelete(comment['id']),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: isDeleting
                    ? 'Deleting...'
                    : 'Delete All Toxic Comments',
                onPressed: !isDeleting ? _handleDeleteAll : () {},
                backgroundColor: AppColors.accentRed,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/history');
              break;
            case 2:
              Navigator.pushNamed(context, '/keywords');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}