import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 0)
class Chapter {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? volume;
  @HiveField(3)
  final String? chapter;
  @HiveField(4)
  final int? pages;
  @HiveField(5)
  final String? url;
  @HiveField(6)
  final String? publishAt;
  @HiveField(7)
  final String? readableAt;
  @HiveField(8)
  final String? scanGroup;
  @HiveField(9)
  final bool? officialScan;
  @HiveField(10)
  bool downloaded;

  Chapter(
      {required this.id,
      required this.title,
      required this.volume,
      required this.chapter,
      required this.pages,
      required this.url,
      required this.publishAt,
      required this.readableAt,
      required this.scanGroup,
      required this.officialScan,
      required this.downloaded});

  void setDownloaded(bool downloaded) {
    this.downloaded = downloaded;
  }
}
