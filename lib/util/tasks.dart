import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/model/manga_details.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/util/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

void updateChaptersTask() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Box libraryBox = Hive.box('library');
  Box mangaDetailsBox = Hive.box<MangaDetails>('mangaDetails');
  Box mangaChaptersBox = Hive.box<List<dynamic>>('mangaChapters');
  NotificationService.initalize(flutterLocalNotificationsPlugin);
  int idx = 1;

  for (var manga in libraryBox.values) {
    MangaSource source = SourceHelper().getSource(manga['source']);

    try {
      // MangaDetails mangaDetails = mangaDetailsBox.get(manga['id']);
      // final mangaDetailsResponse =
      //     await source.mangaDetailsRequest(manga['id']);
      // MangaDetails newMangaDetails =
      //     source.mangaDetailsParse(mangaDetailsResponse);

      // ignore: unused_local_variable
      List<Chapter> mangaChapters =
          List<Chapter>.from(mangaChaptersBox.get(manga['id']));

      final chapterResponse = await source.chapterListRequest(manga['id']);

      List<Chapter> newChapters =
          await source.chapterListParse(chapterResponse);
      if (mangaChaptersBox.containsKey(manga['id'])) {
        List<Chapter> tempChapters =
            List<Chapter>.from(mangaChaptersBox.get(manga['id']));
        tempChapters.removeWhere((element) => element.downloaded == false);
        for (var chap in tempChapters) {
          newChapters[
                  newChapters.indexWhere((element) => element.id == chap.id)]
              .setDownloaded(true);
        }
      }
      // mangaDetailsBox.put(manga['id'], newMangaDetails);
      mangaChaptersBox.put(
          manga['id'],
          List<Chapter>.from(
              newChapters.isEmpty ? mangaChapters : newChapters));
    } catch (e) {
      MangaDetails mangaDetails = mangaDetailsBox.get(manga['id']);
      List<Chapter> mangaChapters =
          List<Chapter>.from(mangaChaptersBox.get(manga['id']));
      mangaDetailsBox.put(manga['id'], mangaDetails);
      mangaChaptersBox.put(manga['id'], List<Chapter>.from(mangaChapters));
    }
    NotificationService.showNotification(
        0,
        "${manga['title']} ($idx/${libraryBox.values.length})",
        '',
        flutterLocalNotificationsPlugin,
        'Chapter_update',
        'Chapter Updates',
        showProgress: true,
        maxProgress: libraryBox.values.length,
        progress: idx);
    idx += 1;
  }
  NotificationService.showNotification(
    0,
    "${idx - 1} update(s) completed",
    '',
    flutterLocalNotificationsPlugin,
    'Chapter_update',
    'Chapter Updates',
  );
}
