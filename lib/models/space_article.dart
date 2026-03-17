class SpaceArticle {
  final int id;
  final String title;
  final String summary;
  final String imageUrl;
  final String newsSite;
  final DateTime publishedAt;
  final String articleUrl;

  const SpaceArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.newsSite,
    required this.publishedAt,
    required this.articleUrl,
  });

  factory SpaceArticle.fromJson(Map<String, dynamic> json) {
    return SpaceArticle(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      imageUrl: (json['image_url'] as String?) ?? '',
      newsSite: (json['news_site'] as String?) ?? 'Space',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      articleUrl: (json['url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'image_url': imageUrl,
        'news_site': newsSite,
        'published_at': publishedAt.toIso8601String(),
        'url': articleUrl,
      };
}
