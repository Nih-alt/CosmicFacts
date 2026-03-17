class NasaImage {
  final String nasaId;
  final String title;
  final String description;
  final String imageUrl;
  final String dateCreated;
  final String center;
  final List<String> keywords;

  const NasaImage({
    required this.nasaId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.dateCreated,
    required this.center,
    required this.keywords,
  });

  factory NasaImage.fromJson(Map<String, dynamic> json, String thumbUrl) {
    return NasaImage(
      nasaId: (json['nasa_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      imageUrl: thumbUrl,
      dateCreated: (json['date_created'] as String?) ?? '',
      center: (json['center'] as String?) ?? 'NASA',
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }
}
