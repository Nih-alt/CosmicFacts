class BookmarkModel {
  final String id;
  final String type; // 'article', 'image', 'apod', 'glossary', 'lesson'
  final String title;
  final String subtitle;
  final String imageUrl;
  final String data; // JSON string of full item data
  final DateTime savedAt;

  BookmarkModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.data = '',
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'data': data,
        'savedAt': savedAt.toIso8601String(),
      };

  factory BookmarkModel.fromJson(Map<String, dynamic> json) => BookmarkModel(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        data: json['data'] as String? ?? '',
        savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
