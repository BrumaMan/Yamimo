class Chapter {
  final String id;
  final String title;
  final String? volume;
  final String? chapter;
  final int? pages;
  final String? url;
  final String? publishAt;
  final String? readableAt;
  final String? scanGroup;
  final bool? officialScan;

  Chapter({
    required this.id,
    required this.title,
    required this.volume,
    required this.chapter,
    required this.pages,
    required this.url,
    required this.publishAt,
    required this.readableAt,
    required this.scanGroup,
    required this.officialScan,
  });
}
