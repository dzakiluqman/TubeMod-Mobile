import 'comment_model.dart';

class AnalyzeResponse {
  final String videoId;
  final String videoTitle;
  final int totalComments;
  final bool isOwner;
  final List<CommentModel> comments;

  AnalyzeResponse({
    required this.videoId,
    required this.videoTitle,
    required this.totalComments,
    required this.isOwner,
    required this.comments,
  });

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      videoId: json['video_id'],
      videoTitle: json['video_title'],
      totalComments: json['total_comments'],
      isOwner: json['is_owner'],
      comments: (json['comments'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
    );
  }
}