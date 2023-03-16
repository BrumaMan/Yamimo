class Manga {
  final String? id;
  final String? title;
  final List<dynamic>? altTitles;
  final String? cover;
  final String? url;
  final String? synopsis;
  final String? type;
  final String? year;
  final String? status;
  final List<dynamic>? tags;
  final String author;

  Manga({
    required this.id,
    required this.title,
    this.altTitles,
    required this.cover,
    this.url,
    required this.synopsis,
    required this.type,
    required this.year,
    required this.status,
    required this.tags,
    required this.author,
  });
}
