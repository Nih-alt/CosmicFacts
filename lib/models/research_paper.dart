// DISCLAIMER: Paper data sourced from arXiv open-access repository (arxiv.org).
// This app is unofficial and not affiliated with arXiv, Cornell University,
// or any research institution.

class ResearchPaper {
  final String id;
  final String title;
  final List<String> authors;
  final String abstract;
  final DateTime published;
  final DateTime updated;
  final String category;
  final String arxivCat;
  final String pdfUrl;
  final String abstractUrl;

  ResearchPaper({
    required this.id,
    required this.title,
    required this.authors,
    required this.abstract,
    required this.published,
    required this.updated,
    required this.category,
    required this.arxivCat,
    required this.pdfUrl,
    required this.abstractUrl,
  });

  bool get isNew => DateTime.now().difference(published).inDays <= 7;

  String get authorsDisplay {
    if (authors.isEmpty) return 'Unknown';
    if (authors.length == 1) return authors[0];
    if (authors.length == 2) return '${authors[0]} & ${authors[1]}';
    return '${authors[0]} et al.';
  }

  int get readTimeMinutes {
    final words = abstract.split(' ').length;
    return ((words / 200) + 5).ceil();
  }
}
