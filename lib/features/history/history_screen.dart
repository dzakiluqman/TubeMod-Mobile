import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/custom_bottom_navbar.dart';
import '../../core/widgets/custom_header.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final int _selectedIndex = 1;
  bool isLoading = true;
  bool isLoadingMore = false;

  List<Map<String, dynamic>> historyList = [];
  int currentPage = 1;
  int totalPages = 1;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Load history dari API
  Future<void> _loadHistory({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMoreData || isLoadingMore) return;
        setState(() => isLoadingMore = true);
        currentPage++;
      } else {
        setState(() => isLoading = true);
        currentPage = 1;
      }

      final result = await ApiService.getHistory(
        page: currentPage,
        limit: 10,
      );

      if (result != null) {
        final pagination = result['pagination'] as Map<String, dynamic>;
        final history = result['history'] as List<dynamic>;

        setState(() {
          if (loadMore) {
            historyList.addAll(
              List<Map<String, dynamic>>.from(history),
            );
          } else {
            historyList = List<Map<String, dynamic>>.from(history);
          }

          totalPages = pagination['pages'] ?? 1;
          hasMoreData = currentPage < totalPages;
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        _showErrorSnackBar('Failed to load history');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      debugPrint('ERROR: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Delete history record
  Future<void> _deleteHistory(int historyId) async {
    try {
      final confirmed = await _showConfirmDialog('Delete this history record?');
      if (!confirmed) return;

      final success = await ApiService.deleteHistory(historyId);

      if (success) {
        setState(() {
          historyList.removeWhere((h) => h['id'] == historyId);
        });
        _showSuccessSnackBar('History deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete history');
      }
    } catch (e) {
      debugPrint('ERROR DELETE: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

  /// Show history detail
  Future<void> _showHistoryDetail(String videoId) async {
    try {
      final result = await ApiService.getHistoryDetail(videoId);

      if (result != null && mounted) {
        final video = result['video'] as Map<String, dynamic>;
        final comments = result['comments'] as Map<String, dynamic>;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (context) => _buildHistoryDetailModal(video, comments),
        );
      }
    } catch (e) {
      debugPrint('ERROR DETAIL: $e');
      _showErrorSnackBar('Failed to load history details');
    }
  }

  Widget _buildHistoryDetailModal(
    Map<String, dynamic> video,
    Map<String, dynamic> comments,
  ) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                video['video_title'] ?? 'Unknown Video',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E004F),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      'Total Comments',
                      '${video['total_comments'] ?? 0}',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Deleted',
                      '${video['deleted_comments'] ?? 0}',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Hidden',
                      '${video['hidden_comments'] ?? 0}',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Toxic Comments (${comments['total'] ?? 0})',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E004F),
                ),
              ),
              const SizedBox(height: 12),
              if ((comments['items'] as List?)?.isEmpty ?? true)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No toxic comments',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (comments['items'] as List).length,
                  itemBuilder: (context, index) {
                    final comment = (comments['items'] as List)[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['author'] ?? 'User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment['comment_text'] ?? '',
                            style: const TextStyle(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: ${comment['category'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black,
            fontSize: 14,
          ),
        ),
      ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom Header dari Core Widgets
              const CustomHeader(
                subtitle: 'One tool to manage\ntoxic comments\nin your YouTube\nchannels.',
              ),

              const SizedBox(height: 30),

              // Title menggunakan warna tema utama (ungu)
              Text(
                'History',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6500A3),
                ),
              ),

              const SizedBox(height: 20),

              // List History
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6500A3),
                    ),
                  ),
                )
              else if (historyList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 60,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No history yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildHistoryList(),

              if (isLoadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6500A3),
                    ),
                  ),
                )
              else if (hasMoreData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () => _loadHistory(loadMore: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6500A3),
                    ),
                    child: const Text('Load More'),
                  ),
                ),

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
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: historyList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = historyList[index];
          return GestureDetector(
            onTap: () => _showHistoryDetail(item['video_id'] ?? ''),
            child: Container(
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
                          item['video_title'] ?? 'Unknown Video',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${item['video_id'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Analyzed: ${_formatDate(item['created_at'])}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatBadge(
                              '${item['total_comments'] ?? 0}',
                              'Total',
                              Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(width: 8),
                            _buildStatBadge(
                              '${item['deleted_comments'] ?? 0}',
                              'Deleted',
                              Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(width: 8),
                            _buildStatBadge(
                              '${item['hidden_comments'] ?? 0}',
                              'Hidden',
                              Colors.white.withOpacity(0.15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteHistory(item['id']),
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Color(0xFFB37FEB),
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBadge(String value, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      return dateString;
    }
  }
}