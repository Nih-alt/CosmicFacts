class NasaImage {
  final String nasaId;
  final String title;
  final String description;
  final String imageUrl;       // medium ~500px — for grid tiles
  final String largeImageUrl;  // large ~1800px — for detail hero
  final String dateCreated;
  final String center;
  final List<String> keywords;

  const NasaImage({
    required this.nasaId,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.largeImageUrl = '',
    required this.dateCreated,
    required this.center,
    required this.keywords,
  });

  factory NasaImage.fromJson(
    Map<String, dynamic> json,
    String thumbUrl, {
    String largeUrl = '',
  }) {
    return NasaImage(
      nasaId: (json['nasa_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      imageUrl: thumbUrl,
      largeImageUrl: largeUrl,
      dateCreated: (json['date_created'] as String?) ?? '',
      center: (json['center'] as String?) ?? 'NASA',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'nasa_id': nasaId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'large_image_url': largeImageUrl,
        'date_created': dateCreated,
        'center': center,
        'keywords': keywords,
      };
}
