import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Overview extends StatelessWidget {
  Overview({super.key});

  Box libraryBox = Hive.box('library');
  Box chapterBox = Hive.box('chapters');
  Box chaptersReadBox = Hive.box('chaptersRead');

  int getCompletedCount({bool started = false}) {
    int completed = 0;
    int chaptersRead = 0;
    var currentChapters;

    for (var manga in libraryBox.values) {
      currentChapters = chaptersReadBox.get(manga['id'], defaultValue: {});
      currentChapters.forEach((key, value) {
        value['read'] == true ? chaptersRead++ : null;
      });
      if (!started) {
        chapterBox.get(manga['id']) != 0 &&
                chapterBox.get(manga['id']) - chaptersRead == 0
            ? completed++
            : null;
      } else {
        chaptersRead != 0 ? completed++ : null;
      }
      chaptersRead = 0;
    }

    return completed;
  }

  num getTotalAmount({bool read = false}) {
    num totalChapters = 0;
    int chaptersRead = 0;

    if (read) {
      for (var chapters in chaptersReadBox.values) {
        chapters.forEach((key, value) {
          if (key != 'chapter' && key != 'page') {
            value['read'] == true ? chaptersRead++ : null;
          }
          // debugPrint('$key: $value');
        });
      }

      return chaptersRead;
    } else {
      for (var numChapters in chapterBox.values) {
        totalChapters += numChapters;
      }

      return totalChapters;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          libraryBox.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        Text('In library')
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getCompletedCount().toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        Text('Completed')
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getCompletedCount(started: true).toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        Text('Started')
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
              child: Text('Chapters'),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getTotalAmount().toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        Text('Total')
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getTotalAmount(read: true).toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        Text('Read')
                      ],
                    ),
                    // Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     Text(
                    //       getCompletedCount(started: true).toString(),
                    //       style: TextStyle(
                    //           fontWeight: FontWeight.bold, fontSize: 20.0),
                    //     ),
                    //     Text('Started')
                    //   ],
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
