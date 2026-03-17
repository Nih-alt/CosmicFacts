class ApodModel {
  final String title;
  final String explanation;
  final String imageUrl;
  final String date;
  final String mediaType;

  const ApodModel({
    required this.title,
    required this.explanation,
    required this.imageUrl,
    required this.date,
    required this.mediaType,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      title: (json['title'] as String?) ?? '',
      explanation: (json['explanation'] as String?) ?? '',
      imageUrl: (json['url'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      mediaType: (json['media_type'] as String?) ?? 'image',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'explanation': explanation,
        'url': imageUrl,
        'date': date,
        'media_type': mediaType,
      };
}
