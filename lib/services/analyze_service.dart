import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/analyze_response.dart';

class AnalyzeService {
  static const String baseUrl =
      'https://tubemod.online/api/analyze';

  Future<AnalyzeResponse> analyzeYoutubeComments({
    required String youtubeUrl,
    required String jwtToken,
    required String googleAccessToken,
    bool filterFonts = true,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({
        'youtube_url': youtubeUrl,
        'google_access_token': googleAccessToken,
        'filter_fonts': filterFonts,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AnalyzeResponse.fromJson(data['data']);
    } else {
      throw Exception(data['message']);
    }
  }
}