class CommentModel {
  final String id;
  final String author;
  final String text;
  final bool isToxic;
  final String matchedKeyword;
  final String category;

  CommentModel({
    required this.id,
    required this.author,
    required this.text,
    required this.isToxic,
    required this.matchedKeyword,
    required this.category,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      text: json['text'] ?? '',
      isToxic: json['is_toxic'] ?? false,
      matchedKeyword: json['matched_keyword'] ?? '',
      category: json['category'] ?? '',
    );
  }
}