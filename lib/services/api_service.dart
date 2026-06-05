// lib/services/api_service.dart
// 
// Example of how to use the proxy for all API endpoints
// Replace your existing direct API calls with these proxy-based methods

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://tubemod.online';

  /// ============= ANALYZE ENDPOINTS =============

  /// POST /api/analyze
  /// Analyze YouTube video comments
  static Future<Map<String, dynamic>?> analyzeComments({
    required String youtubeUrl,
    String? googleAccessToken,
    bool filterFonts = false,
  }) async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'analyze',
        method: 'POST',
        data: {
          'youtube_url': youtubeUrl,
          'google_access_token': googleAccessToken,
          'filter_fonts': filterFonts,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        if (jsonResponse?['status'] == 'success') {
          return jsonResponse?['data'];
        } else {
          developer.log('[ApiService] Analyze error: ${jsonResponse?['message']}');
        }
      } else {
        developer.log('[ApiService] Analyze failed with code ${response.statusCode}');
      }
      return null;
    } catch (e) {
      developer.log('[ApiService] Error analyzing comments', error: e);
      return null;
    }
  }

  /// POST /api/analyze/deleteSingle
  /// Delete a single comment
  static Future<bool> deleteSingleComment({
    required String commentId,
    required String googleAccessToken,
  }) async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'analyze_delete_single',
        method: 'POST',
        data: {
          'comment_id': commentId,
          'google_access_token': googleAccessToken,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        return jsonResponse?['status'] == 'success';
      }
      return false;
    } catch (e) {
      developer.log('[ApiService] Error deleting single comment', error: e);
      return false;
    }
  }

  /// POST /api/analyze/deleteAll
  /// Bulk delete toxic comments
  static Future<Map<String, dynamic>?> deleteAllToxicComments({
    required String googleAccessToken,
    required String videoId,
    required String videoTitle,
    required int totalComments,
    required List<Map<String, dynamic>> toxicComments,
  }) async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'analyze_delete_all',
        method: 'POST',
        data: {
          'google_access_token': googleAccessToken,
          'video_id': videoId,
          'video_title': videoTitle,
          'total_comments': totalComments,
          'toxic_comments': toxicComments,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        if (jsonResponse?['status'] == 'success') {
          return jsonResponse?['data'];
        }
      }
      return null;
    } catch (e) {
      developer.log('[ApiService] Error deleting all toxic comments', error: e);
      return null;
    }
  }

  /// ============= KEYWORD ENDPOINTS =============

  /// GET /api/keyword
  /// Get all user keywords
  static Future<List<Map<String, dynamic>>?> getKeywords() async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'keyword',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        if (jsonResponse?['status'] == 'success') {
          final data = jsonResponse?['data'];
          if (data is List) {
            return List<Map<String, dynamic>>.from(data);
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('[ApiService] Error fetching keywords', error: e);
      return null;
    }
  }

  /// POST /api/keyword/add
  /// Add a new keyword
  static Future<bool> addKeyword({
    required String word,
    required String category,
  }) async {
    try {
      if (word.isEmpty || category.isEmpty) {
        developer.log('[ApiService] Word and category cannot be empty');
        return false;
      }

      final response = await AuthService().makeProxyRequest(
        action: 'keyword_add',
        method: 'POST',
        data: {
          'word': word,
          'category': category,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        return jsonResponse?['status'] == 'success';
      }
      return false;
    } catch (e) {
      developer.log('[ApiService] Error adding keyword', error: e);
      return false;
    }
  }

  /// PUT/POST /api/keyword/update
  /// Update an existing keyword
  static Future<bool> updateKeyword({
    required int id,
    required String word,
    required String category,
  }) async {
    try {
      if (word.isEmpty || category.isEmpty) {
        developer.log('[ApiService] Word and category cannot be empty');
        return false;
      }

      final response = await AuthService().makeProxyRequest(
        action: 'keyword_update',
        method: 'PUT',
        data: {
          'id': id,
          'word': word,
          'category': category,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        return jsonResponse?['status'] == 'success';
      }
      return false;
    } catch (e) {
      developer.log('[ApiService] Error updating keyword', error: e);
      return false;
    }
  }

  /// DELETE /api/keyword/delete/{id}
  /// Delete a keyword
  static Future<bool> deleteKeyword(int id) async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'keyword_delete',
        method: 'DELETE',
        data: {
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        return jsonResponse?['status'] == 'success';
      }
      return false;
    } catch (e) {
      developer.log('[ApiService] Error deleting keyword', error: e);
      return false;
    }
  }

  /// ============= HISTORY ENDPOINTS =============

  /// GET /api/history
  /// Get user's moderation history
  static Future<List<Map<String, dynamic>>?> getHistory() async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'history',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        if (jsonResponse?['status'] == 'success') {
          final data = jsonResponse?['data'];
          if (data is List) {
            return List<Map<String, dynamic>>.from(data);
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('[ApiService] Error fetching history', error: e);
      return null;
    }
  }

  /// DELETE /api/history/delete/{id}
  /// Delete a history record
  static Future<bool> deleteHistoryRecord(int id) async {
    try {
      final response = await AuthService().makeProxyRequest(
        action: 'history_delete',
        method: 'DELETE',
        data: {
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = _safeJsonDecode(response.body);
        return jsonResponse?['status'] == 'success';
      }
      return false;
    } catch (e) {
      developer.log('[ApiService] Error deleting history record', error: e);
      return false;
    }
  }

  /// ============= HELPER METHODS =============

  /// Safely decode JSON response
  static Map<String, dynamic>? _safeJsonDecode(String jsonString) {
    try {
      if (jsonString.isEmpty) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('[ApiService] JSON decode error', error: e);
      return null;
    }
  }

  /// Handle API error responses
  static String? extractErrorMessage(http.Response response) {
    try {
      final jsonResponse = _safeJsonDecode(response.body);
      return jsonResponse?['message'] ?? 'Unknown error';
    } catch (e) {
      return 'Failed to parse error response';
    }
  }
}

/// ============= USAGE EXAMPLES =============

/*
// Example 1: Analyze comments
void analyzeVideo() async {
  final result = await ApiService.analyzeComments(
    youtubeUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    googleAccessToken: 'your_access_token',
    filterFonts: true,
  );

  if (result != null) {
    print('Total comments: ${result['total_comments']}');
    print('Toxic comments: ${result['toxic_comments_count']}');
  } else {
    print('Analysis failed');
  }
}

// Example 2: Add keyword
void addNewKeyword() async {
  final success = await ApiService.addKeyword(
    word: 'spam',
    category: 'Spam',
  );

  if (success) {
    print('Keyword added successfully');
  } else {
    print('Failed to add keyword');
  }
}

// Example 3: Get all keywords
void loadKeywords() async {
  final keywords = await ApiService.getKeywords();

  if (keywords != null) {
    for (var kw in keywords) {
      print('${kw['word']} - ${kw['category']}');
    }
  } else {
    print('Failed to load keywords');
  }
}

// Example 4: Bulk delete toxic comments
void cleanToxicComments(List<Map<String, dynamic>> toxicComments) async {
  final result = await ApiService.deleteAllToxicComments(
    googleAccessToken: 'your_access_token',
    videoId: 'dQw4w9WgXcQ',
    videoTitle: 'My Awesome Video',
    totalComments: 150,
    toxicComments: toxicComments,
  );

  if (result != null) {
    print('Deleted: ${result['deleted_count']}');
    print('Hidden: ${result['hidden_count']}');
  }
}

// Example 5: Get moderation history
void loadHistory() async {
  final history = await ApiService.getHistory();

  if (history != null) {
    for (var record in history) {
      print('${record['video_title']} - ${record['deleted_comments']} deleted');
    }
  }
}
*/