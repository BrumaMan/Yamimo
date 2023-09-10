import 'dart:io';

import 'package:dio/dio.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/util/notification_service.dart';
import 'package:first_app/util/request_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloader {
  Downloader({required this.chapters});

  final List<Chapter> chapters;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Dio dio = Dio();
  late Directory downloadsDir;
  bool downloading = false;
  Box mangaChaptersBox = Hive.box<List<dynamic>>('mangaChapters');

  Future<bool> downloadChapter(
      String source,
      String title,
      String mangaID,
      Chapter chapter,
      Function(double total, bool downloading) onProgress,
      Function(String error) onError) async {
    try {
      if (await requestPermission(Permission.manageExternalStorage)) {
        Directory dir = await getExternalStorageDirectory() as Directory;
        downloadsDir =
            Directory("${dir.path}/downloads/$source/$title/${chapter.title}");
      } else {
        return false;
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      if (await downloadsDir.exists()) {
        MangaSource pageSource = SourceHelper().getSource(source);
        final response = await pageSource.pageListRequest(chapter);
        List<String> pages = pageSource.pageListParse(response);
        int index = 1;
        for (var page in pages) {
          // File pageFile = File("${downloadsDir.path}/${index}.jpg");
          debugPrint("downloading page: $index");
          await dio.download(
            page,
            "${downloadsDir.path}/${index}.jpg",
            onReceiveProgress: (count, total) {
              if (total != -1) {
                // debugPrint((count / total * 100).toStringAsFixed(0) + '%');
              }
            },
          );
          downloading = true;
          onProgress(index / pages.length, downloading);
          index += 1;
        }
        downloading = false;
        onProgress(1.0, downloading);
        chapters[chapters.indexWhere((element) => element.id == chapter.id)]
            .setDownloaded(true);
        // debugPrint(
        //     "${chapters[chapters.indexWhere((element) => element.id == chapter.id)].downloaded}");
        mangaChaptersBox.put(mangaID, List<Chapter>.from(chapters));
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      onProgress(1.0, false);
      onError(e.toString());
    }
    return false;
  }

  Future<bool> downloadAll(
      String source,
      String title,
      String mangaID,
      Map<dynamic, dynamic> chaptersRead,
      Function(double total, bool downloading, String currentChapter)
          onDownloadProgress,
      Function(String error) onErrorRecieved) async {
    NotificationService.initalize(flutterLocalNotificationsPlugin);
    int idx = 1;

    try {
      chaptersRead.removeWhere((key, value) => value['read'] == false);
      for (var chapter in chapters) {
        if (!chapter.downloaded) {
          if (!chaptersRead.containsKey(chapter.id)) {
            NotificationService.showNotification(
                1,
                title,
                '${chapter.title} ($idx/${chapters.length - chaptersRead.length})',
                flutterLocalNotificationsPlugin,
                'Chapter_download',
                'Chapter Downloads',
                showProgress: true,
                maxProgress: chapters.length - chaptersRead.length,
                progress: idx);
            await downloadChapter(
              source,
              title,
              mangaID,
              chapter,
              (total, downloading) =>
                  onDownloadProgress(total, downloading, chapter.id),
              (error) => onErrorRecieved(error),
            );
            idx += 1;
          } else {
            continue;
          }
        } else {
          idx += 1;
          continue;
        }
      }
      NotificationService.showNotification(
        1,
        title,
        '$idx chapter(s) downloaded',
        flutterLocalNotificationsPlugin,
        'Chapter_download',
        'Chapter Downloads',
      );
    } catch (e) {
      debugPrint(e.toString());
      onDownloadProgress(1.0, false, "");
      onErrorRecieved(e.toString());
      NotificationService.showNotification(
        1,
        title,
        '$idx chapter(s) downloaded and failed on chapter ${chapters.length - idx}',
        flutterLocalNotificationsPlugin,
        'Chapter_download',
        'Chapter Downloads',
      );
    }
    return false;
  }

  Future<bool> deletePages(
    String source,
    String title,
    String mangaID,
    Chapter chapter,
    Function(double total, bool downloading) onProgress,
  ) async {
    Directory dir = await getExternalStorageDirectory() as Directory;
    downloadsDir =
        Directory("${dir.path}/downloads/$source/$title/${chapter.title}");

    if (await downloadsDir.exists()) {
      List<FileSystemEntity> pages = downloadsDir.listSync();
      int index = pages.length;
      for (FileSystemEntity page in pages) {
        if (index > 0) {
          onProgress(index / pages.length, true);
          debugPrint("deleting: ${page.path}");
          await page.delete();
          index -= 1;
        }
        // debugPrint(page.path);
      }
      onProgress(0.0, false);
      chapters[chapters.indexWhere((element) => element.id == chapter.id)]
          .setDownloaded(false);
      mangaChaptersBox.put(mangaID, List<Chapter>.from(chapters));
      return true;
    }
    return false;
  }

  Future<List<String>> getDownladedPages(
    String source,
    String title,
    String chapterTitle,
  ) async {
    List<String> chapPages = [];
    Directory dir = await getExternalStorageDirectory() as Directory;
    downloadsDir =
        Directory("${dir.path}/downloads/$source/$title/$chapterTitle");

    if (await downloadsDir.exists()) {
      List<FileSystemEntity> pages = downloadsDir.listSync();
      for (FileSystemEntity page in pages) {
        chapPages.add(page.path);
        debugPrint(page.path);
      }
    }
    return chapPages;
  }
}
