class Manga {
  final String? id;
  final String? title;
  final List<dynamic>? altTitles;
  final String? cover;
  final String? url;

  Manga({
    required this.id,
    required this.title,
    this.altTitles,
    required this.cover,
    this.url,
  });
}
