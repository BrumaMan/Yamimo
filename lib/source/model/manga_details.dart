import 'package:hive/hive.dart';

part 'manga_details.g.dart';

@HiveType(typeId: 1)
class MangaDetails extends HiveObject {
  @HiveField(0)
  final String synopsis;
  @HiveField(1)
  final String? type;
  @HiveField(2)
  final String year;
  @HiveField(3)
  final String status;
  @HiveField(4)
  final List<dynamic>? tags;
  @HiveField(5)
  final String author;

  MangaDetails({
    required this.synopsis,
    required this.type,
    required this.year,
    required this.status,
    required this.tags,
    required this.author,
  });
}
