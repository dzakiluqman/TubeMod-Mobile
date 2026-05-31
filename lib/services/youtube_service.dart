import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeService {
  static String get apiKey =>
      dotenv.env['YOUTUBE_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> fetchComments(
    String videoId,
  ) async {
    final url =
        'https://www.googleapis.com/youtube/v3/commentThreads'
        '?part=snippet'
        '&videoId=$videoId'
        '&maxResults=20'
        '&key=$apiKey';

    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List items = data['items'];

      return items.map((item) {
        final snippet =
            item['snippet']['topLevelComment']['snippet'];

        return {
          'username': snippet['authorDisplayName'],
          'comment': snippet['textDisplay'],
        };
      }).toList();
    } else {
      throw Exception(
        'Failed to load comments: ${response.statusCode}\n${response.body}',
      );
    }
  }
}