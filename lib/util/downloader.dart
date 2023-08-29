import 'dart:io';

import 'package:dio/dio.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/util/request_permission.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloader {
  Downloader({required this.chapters});

  final List<Chapter> chapters;
  Dio dio = Dio();
  late Directory downloadsDir;
  bool downloading = false;
  Box mangaChaptersBox = Hive.box<List<dynamic>>('mangaChapters');

  Future<bool> downloadChapter(
      String source,
      String title,
      String mangaID,
      Chapter chapter,
      Function(int count, int total, bool downloading) onProgress,
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
                if (!downloading) {
                  downloading = true;
                  onProgress(count, total, downloading);
                }
              }
            },
          );
          index += 1;
        }
        downloading = false;
        onProgress(0, 0, downloading);
        chapters[chapters.indexWhere((element) => element.id == chapter.id)]
            .setDownloaded(true);
        // debugPrint(
        //     "${chapters[chapters.indexWhere((element) => element.id == chapter.id)].downloaded}");
        mangaChaptersBox.put(mangaID, List<Chapter>.from(chapters));
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
      onProgress(0, 0, false);
      onError(e.toString());
    }
    return false;
  }

  Future<bool> downloadAll(
      String source,
      String title,
      String mangaID,
      Map<dynamic, dynamic> chaptersRead,
      Function(int count, int total, bool downloading, String currentChapter)
          onDownloadProgress,
      Function(String error) onErrorRecieved) async {
    try {
      chaptersRead.removeWhere((key, value) => value['read'] == false);
      for (var chapter in chapters) {
        if (chapter.downloaded) {
          if (!chaptersRead.containsKey(chapter.id)) {
            await downloadChapter(
              source,
              title,
              mangaID,
              chapter,
              (count, total, downloading) =>
                  onDownloadProgress(count, total, downloading, chapter.id),
              (error) => onErrorRecieved(error),
            );
          } else {
            continue;
          }
        } else {
          continue;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      onDownloadProgress(0, 0, false, "");
      onErrorRecieved(e.toString());
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
