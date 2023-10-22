// ignore_for_file: must_call_super

import 'package:first_app/item_view.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/util/globals.dart';
import 'package:first_app/util/notification_service.dart';
import 'package:first_app/util/page_animation_wrapper.dart';
import 'package:first_app/widgets/manga_longpress_modal.dart';
// import 'package:first_app/widgets/library_filter_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class LibraryDeleteNotifier {
  ValueNotifier itemDeleted = ValueNotifier(0);

  void increment() {
    itemDeleted.value++;
  }
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  Box libraryBox = Hive.box('library');
  Box settingsBox = Hive.box('settings');
  Box chapterBox = Hive.box('chapters');
  Box chaptersReadBox = Hive.box('chaptersRead');
  late List<dynamic> libraryItems;
  List<dynamic> mangaChapters = [];
  late int itemsPerRow;
  LibraryDeleteNotifier libraryDeleteNotifier = LibraryDeleteNotifier();
  int updateCount = 0;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsPerRow = settingsBox.get('rowItems', defaultValue: 2);
    libraryItems = getLibraryItems();
    NotificationService.initalize(flutterLocalNotificationsPlugin);

    // debugPrint('$libraryItems');
  }

  List<dynamic> getLibraryItems() {
    List<dynamic> libraryItems = [];

    for (var comic in libraryBox.values) {
      libraryItems.add(comic);
    }

    // for (var chapters in chapterBox.values) {
    //   mangaChapters.add(chapters);
    // }
    libraryItems.sort((a, b) => a['title'].compareTo(b['title']));

    return libraryItems;
  }

  int chaptersRead(String id) {
    var chaptersRead = chaptersReadBox.get(id, defaultValue: {});

    if (chaptersRead['chapter'] != null) {
      chaptersReadBox.delete(id);
      chaptersRead = chaptersReadBox.get(id, defaultValue: {});
    }

    // debugPrint('$chaptersRead');
    int numRead = 0;

    chaptersRead.forEach((key, value) {
      if (value['read'] == true) {
        numRead++;
      }
    });

    return numRead;
  }

  void deleteFromLibrary(String id) {
    // libraryDeleteNotifier.increment();
    // libraryItems.removeAt(index);
    // mangaChapters.removeAt(index);

    libraryBox.delete(id);
    chapterBox.delete(id);

    libraryItems = getLibraryItems();

    // for (var comic in libraryItems) {
    //   libraryBox.put(comic['id'], comic);
    // }

    // for (var chapters in mangaChapters) {
    //   chapterBox.put(libraryItems[count]['id'], chapters);
    //   count++;
    // }
  }

  void updateLibraryItems() async {
    var libraryItems = libraryBox.values;
    snackbarKey.currentState?.showSnackBar(SnackBar(
      content: Text('Updating'),
      behavior: SnackBarBehavior.floating,
    ));
    for (var item in libraryItems) {
      MangaSource source = SourceHelper().getSource(item['source']);
      String id = item['id'];
      DateTime addedAt = item['addedAt'];
      Response updateResponse = await source.updateLibraryRequest(id);
      var newDetails = source.updateLibraryParse(updateResponse);

      libraryBox.put(id, {
        'id': id,
        'title': newDetails["title"],
        'cover': newDetails["cover"],
        'url': newDetails["url"],
        'addedAt': addedAt,
        'source': newDetails["source"],
      });

      setState(() {
        updateCount++;
      });
    }

    setState(() {
      updateCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(updateCount == 0
              ? 'Library'
              : 'Library($updateCount of ${libraryBox.length})'),
          actions: [
            IconButton(
                onPressed: () => updateLibraryItems(),
                icon: Icon(Icons.refresh)),
            // IconButton(
            //     onPressed: () {
            //       showModalBottomSheet(
            //         context: context,
            //         builder: (context) => LibraryFilter(),
            //       );
            //     },
            //     icon: Icon(Icons.filter_list))
          ],
        ),
        body: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor:
                MaterialStatePropertyAll(Theme.of(context).colorScheme.primary),
            crossAxisMargin: 6.0,
          ),
          child: Scrollbar(
            radius: Radius.circular(8.0),
            thickness: 8.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: CustomScrollView(
                controller: homeScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // SliverAppBar(
                  //   title: Text(updateCount == 0
                  //       ? 'Library'
                  //       : 'Library($updateCount of ${libraryBox.length})'),
                  //   floating: true,
                  //   actions: [
                  //     IconButton(
                  //         onPressed: () => updateLibraryItems(),
                  //         icon: Icon(Icons.refresh))
                  //     // IconButton(
                  //     //     onPressed: () {
                  //     //       showBottomSheet(
                  //     //         context: context,
                  //     //         builder: (context) => LibraryFilter(),
                  //     //       );
                  //     //     },
                  //     //     icon: Icon(Icons.filter_list))
                  //   ],
                  // ),
                  ValueListenableBuilder(
                      valueListenable: chaptersReadBox.listenable(),
                      builder: (context, value, child) {
                        return ValueListenableBuilder(
                            valueListenable: libraryBox.listenable(),
                            builder: ((context, value, child) {
                              if (libraryBox.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    // heightFactor: 30,
                                    child: Text("No manga in library"),
                                  ),
                                );
                              } else {
                                return SliverGrid.builder(
                                    // controller: homeScrollController,
                                    // padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: itemsPerRow,
                                      childAspectRatio: 0.67,
                                      mainAxisSpacing: 5.0,
                                      crossAxisSpacing: 5.0,
                                    ),
                                    itemCount: libraryItems.length,
                                    itemBuilder: ((context, index) {
                                      return GestureDetector(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0))),
                                          clipBehavior: Clip.hardEdge,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Hero(
                                                tag: libraryItems[index]
                                                    ["cover"],
                                                child: OptimizedCacheImage(
                                                  placeholder: (context, url) =>
                                                      Container(),
                                                  imageUrl: libraryItems[index]
                                                      ["cover"],
                                                  fit: BoxFit.cover,
                                                  errorWidget: (context, error,
                                                          stackTrace) =>
                                                      Center(
                                                    child: Text(
                                                        "Can't load cover"),
                                                  ),
                                                  // height: 60.0,
                                                ),
                                              ),
                                              Visibility(
                                                visible: chapterBox.get(
                                                            libraryItems[index]
                                                                ['id']) -
                                                        chaptersRead(
                                                            libraryItems[index]
                                                                ["id"]) !=
                                                    0,
                                                child: Positioned(
                                                    top: 0.0,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5.0))),
                                                      margin:
                                                          EdgeInsets.all(4.0),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5.0,
                                                          vertical: 2.0),
                                                      // clipBehavior: Clip.hardEdge,
                                                      // color: Colors.blue,
                                                      child: Text(
                                                        "${chaptersRead(libraryItems[index]["id"])}/${chapterBox.get(libraryItems[index]['id'])}",
                                                        style: TextStyle(
                                                            color: settingsBox.get(
                                                                    "darkMode",
                                                                    defaultValue:
                                                                        false)
                                                                ? Colors.black
                                                                : Colors.white),
                                                      ),
                                                    )),
                                              ),
                                              Positioned(
                                                child: Container(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          begin: Alignment
                                                              .bottomCenter,
                                                          end: Alignment
                                                              .topCenter,
                                                          colors: [
                                                        Colors.black
                                                            .withOpacity(0.8),
                                                        Colors.black
                                                            .withOpacity(0.0)
                                                      ])),
                                                  padding: EdgeInsets.all(5.0),
                                                  height: 80,
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          itemsPerRow -
                                                      13,
                                                  child: Text(
                                                    libraryItems[index]
                                                        ["title"],
                                                    softWrap: true,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        shadows: [
                                                          Shadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.8),
                                                              offset:
                                                                  Offset(0, 1))
                                                        ]),
                                                  ),
                                                ),
                                                bottom: 0.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(PageAnimationWrapper(
                                            key: ValueKey('Manga details'),
                                            screen: ItemView(
                                              id: libraryItems[index]["id"],
                                              title: libraryItems[index]
                                                  ["title"],
                                              cover: libraryItems[index]
                                                  ["cover"],
                                              url: libraryItems[index]["url"] ??
                                                  libraryItems[index]["title"],
                                              source: libraryItems[index]
                                                  ["source"],
                                              // scrapeDate: snapshot.data[index].scrapeDate,
                                            ),
                                          ));
                                        },
                                        onLongPress: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return LongPressModal(
                                                imageURL: libraryItems[index]
                                                    ['cover'],
                                                title: libraryItems[index]
                                                    ['title'],
                                                url: libraryItems[index]['url'],
                                                read: chaptersRead(
                                                    libraryItems[index]["id"]),
                                                total: chapterBox.get(
                                                    libraryItems[index]['id']),
                                                source: libraryItems[index]
                                                    ['source'],
                                                onDelete: () =>
                                                    deleteFromLibrary(
                                                        libraryItems[index]
                                                            ["id"]),
                                              );
                                            },
                                          );
                                          // debugPrint(index.toString());
                                        },
                                      );
                                    }));
                              }
                            }));
                      }),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 10.0,
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
