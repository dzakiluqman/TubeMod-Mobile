import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/utils/session_manager.dart';

class ApiService {
  static const String baseUrl = 'https://1176-27-124-95-122.ngrok-free.app/TUBEMOD-NGROK';

  static bool filterNonOriginalFonts = false;

  static Future<http.Response> _request(
    String endpoint,
    String method, {
    Map<String, dynamic>? data,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    // Mengambil header otomatis dari SessionManager
    final headers = SessionManager.instance.getAuthHeaders();
    headers['ngrok-skip-browser-warning'] = 'true'; // Bypass Ngrok

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          return await http.post(
            url,
            headers: headers,
            body: jsonEncode(data),
          ).timeout(const Duration(seconds: 40));
        case 'PUT':
          return await http.put(
            url,
            headers: headers,
            body: jsonEncode(data),
          ).timeout(const Duration(seconds: 40));
        case 'DELETE':
          return await http.delete(
            url,
            headers: headers,
            body: jsonEncode(data),
          ).timeout(const Duration(seconds: 40));
        case 'GET':
        default:
          return await http.get(
            url,
            headers: headers,
          ).timeout(const Duration(seconds: 40));
      }
    } catch (e) {
      print('====== [API ERROR] Request failed: $e ======');
      rethrow;
    }
  }

  // ==================== ANALYZE ENDPOINTS ====================

  /// Analyze YouTube video comments
  static Future<Map<String, dynamic>?> analyzeVideo({
    required String youtubeUrl,
    bool? applyFontFilter,
  }) async {
    try {
      final response = await _request(
        '/api/analyze',
        'POST',
        data: {
          'youtube_url': youtubeUrl,
          'apply_font_filter': applyFontFilter ?? ApiService.filterNonOriginalFonts,
        },
      );

      print('====== [API DEBUG] Analyze Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        } else {
          print('====== [API ERROR] ${json['message']} ======');
        }
      } else {
        print('====== [API ERROR] Status: ${response.statusCode} ======');
      }
    } catch (e) {
      print('====== [API ERROR] Analyze: $e ======');
    }
    return null;
  }

  /// Delete single comment
  static Future<bool> deleteComment({
    required String commentId,
  }) async {
    try {
      final response = await _request(
        '/api/analyze/delete',
        'POST',
        data: {
          'comment_id': commentId,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'success';
      }
    } catch (e) {
      print('====== [API ERROR] Delete Comment: $e ======');
    }
    return false;
  }

  /// Delete all toxic comments
  static Future<Map<String, dynamic>?> deleteAllComments({
    required List<Map<String, dynamic>> comments,
    required String videoId,
    required String videoTitle,
    required int totalComments,
  }) async {
    try {
      final response = await _request(
        '/api/analyze/delete-all',
        'POST',
        data: {
          'comments': comments,
          'video_id': videoId,
          'video_title': videoTitle,
          'total_comments': totalComments,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        }
      }
    } catch (e) {
      print('====== [API ERROR] Delete All Comments: $e ======');
    }
    return null;
  }

  // ==================== KEYWORD ENDPOINTS ====================

  /// Get all keywords for user
  static Future<List<Map<String, dynamic>>?> getKeywords() async {
    try {
      final response = await _request('/api/keyword', 'GET');

      print('====== [API DEBUG] Keywords Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final data = json['data'] as Map<String, dynamic>;
          return List<Map<String, dynamic>>.from(data['keywords'] ?? []);
        } else {
          print('====== [API ERROR] ${json['message']} ======');
        }
      }
    } catch (e) {
      print('====== [API ERROR] Get Keywords: $e ======');
    }
    return null;
  }

  /// Add new keyword
  static Future<bool> addKeyword({
    required String word,
    required String category,
  }) async {
    try {
      final response = await _request(
        '/api/keyword',
        'POST',
        data: {
          'word': word,
          'category': category,
        },
      );

      print('====== [API DEBUG] Add Keyword Status: ${response.statusCode} ======');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['status'] == 'success';
      }
    } catch (e) {
      print('====== [API ERROR] Add Keyword: $e ======');
    }
    return false;
  }

  /// Update existing keyword
  static Future<bool> updateKeyword({
    required int keywordId,
    required String word,
    required String category,
  }) async {
    try {
      final response = await _request(
        '/api/keyword',
        'PUT',
        data: {
          'id': keywordId,
          'word': word,
          'category': category,
        },
      );

      print('====== [API DEBUG] Update Keyword Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'success';
      }
    } catch (e) {
      print('====== [API ERROR] Update Keyword: $e ======');
    }
    return false;
  }

  /// Delete keyword
  static Future<bool> deleteKeyword(int keywordId) async {
    try {
      final response = await _request(
        '/api/keyword',
        'DELETE',
        data: {
          'id': keywordId,
        },
      );

      print('====== [API DEBUG] Delete Keyword Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'success';
      }
    } catch (e) {
      print('====== [API ERROR] Delete Keyword: $e ======');
    }
    return false;
  }

  // ==================== HISTORY ENDPOINTS ====================

  /// Get all analysis history with pagination
  static Future<Map<String, dynamic>?> getHistory({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _request(
        '/api/history?page=$page&limit=$limit',
        'GET',
      );

      print('====== [API DEBUG] History Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        } else {
          print('====== [API ERROR] ${json['message']} ======');
        }
      }
    } catch (e) {
      print('====== [API ERROR] Get History: $e ======');
    }
    return null;
  }

  /// Get history detail for specific video
  static Future<Map<String, dynamic>?> getHistoryDetail(String videoId) async {
    try {
      final response = await _request(
        '/api/history/detail',
        'POST',
        data: {
          'video_id': videoId,
        },
      );

      print('====== [API DEBUG] History Detail Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        }
      }
    } catch (e) {
      print('====== [API ERROR] Get History Detail: $e ======');
    }
    return null;
  }

  /// Delete history record
  static Future<bool> deleteHistory(int historyId) async {
    try {
      final response = await _request(
        '/api/history/delete',
        'POST',
        data: {
          'id': historyId,
        },
      );

      print('====== [API DEBUG] Delete History Status: ${response.statusCode} ======');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['status'] == 'success';
      }
    } catch (e) {
      print('====== [API ERROR] Delete History: $e ======');
    }
    return false;
  }

  /// Search history by query
  static Future<List<Map<String, dynamic>>?> searchHistory(String query) async {
    try {
      final response = await _request(
        '/api/history/search',
        'POST',
        data: {
          'query': query,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          final data = json['data'] as Map<String, dynamic>;
          return List<Map<String, dynamic>>.from(data['results'] ?? []);
        }
      }
    } catch (e) {
      print('====== [API ERROR] Search History: $e ======');
    }
    return null;
  }

  /// Get user statistics
  static Future<Map<String, dynamic>?> getStatistics() async {
    try {
      final response = await _request('/api/history/stats', 'GET');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          return json['data'];
        }
      }
    } catch (e) {
      print('====== [API ERROR] Get Statistics: $e ======');
    }
    return null;
  }
}