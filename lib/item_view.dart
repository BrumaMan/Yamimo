import 'dart:ui';

import 'package:first_app/chapter_view.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/model/manga_details.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/util/globals.dart';
import 'package:first_app/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

class ItemView extends StatefulWidget {
  const ItemView(
      {super.key,
      required this.id,
      required this.title,
      required this.cover,
      required this.url,
      required this.source
      // required this.scrapeDate,
      });

  final String id;
  final String title;
  final String cover;
  final String url;
  final String source;
  // final String scrapeDate;

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> with TickerProviderStateMixin {
  late ScrollController scrollViewController;
  late AnimationController _controller;
  Box settingsBox = Hive.box('settings');
  Box libraryBox = Hive.box('library');
  Box chapterBox = Hive.box('chapters');
  Box chaptersReadBox = Hive.box('chaptersRead');
  Box mangaDetailsBox = Hive.box<MangaDetails>('mangaDetails');
  Box mangaChaptersBox = Hive.box<List<dynamic>>('mangaChapters');
  List<Widget> tagsWidget = [];
  List<dynamic> tags = [];
  var chaptersRead;
  var chapters;
  var nextChapters;
  var chaptersPassed;
  var mangaDetails;
  int missingChapters = 0;
  int chapterCount = 0;
  double position = 0.0;
  bool isUp = true;
  bool fetchingData = true;
  bool started = false;
  late MangaSource source;
  late List<Color> gradientColors;
  late Color appBarColor;
  late Animation<Color?> _animation;

  double sensitivityFactor = 20.0;

  @override
  void initState() {
    super.initState();
    gradientColors = settingsBox.get('darkMode', defaultValue: false)
        ? [Colors.black, Colors.black.withOpacity(0.7)]
        : [Colors.white, Colors.white.withOpacity(0.6)];
    appBarColor = settingsBox.get('darkMode', defaultValue: false)
        ? Colors.black
        : Colors.white;
    chaptersRead = chaptersReadBox.get(widget.id, defaultValue: {});
    if (chaptersRead['chapter'] != null) {
      chaptersReadBox.delete(widget.id);
      chaptersRead = chaptersReadBox.get(widget.id, defaultValue: {});
    }
    scrollViewController = ScrollController();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    // textController = TextEditingController(text: widget.searchTerm);
    _animation =
        ColorTween(begin: appBarColor.withOpacity(0.02), end: appBarColor)
            .animate(_controller)
          ..addListener(() {
            setState(() {});
          });
    source = SourceHelper().getSource(widget.source);
    mangaDetails = getMangaDetails();
    chapters = getRequest();
    // nextChapters = chapters as List<Chapter>;
    // debugPrint('${scrollViewController.positions}');
  }

  @override
  void dispose() {
    // textController.dispose();
    scrollViewController.dispose();
    _controller.dispose();
    snackbarKey.currentState?.clearSnackBars();
    super.dispose();
  }

  List<Widget> getTags(List<dynamic> mangaTags) {
    // widget.tags!
    //     .removeWhere((element) => element["attributes"]["group"] != 'genre');
    List<Widget> tagsWidgets = [];
    tagsWidgets = source.getGenres(mangaTags);
    setState(() {
      tags = mangaTags;
    });
    return tagsWidgets;
  }

  Future<MangaDetails> getMangaDetails() async {
    late MangaDetails mangaDetails;
    if (mangaDetailsBox.containsKey(widget.id)) {
      mangaDetails = mangaDetailsBox.get(widget.id);
    } else {
      final mangaDetailsResponse = await source.mangaDetailsRequest(widget.id);
      mangaDetails = source.mangaDetailsParse(mangaDetailsResponse);
      mangaDetailsBox.put(widget.id, mangaDetails);
    }
    tagsWidget = getTags(mangaDetails.tags!);
    // debugPrint(mangaDetails.synopsis);
    return mangaDetails;
  }

  Future<List<Chapter>> getRequest({refresh = false}) async {
    late List<Chapter> chapters;
    if (mangaChaptersBox.containsKey(widget.id) && refresh == false) {
      List<Chapter> tempChapters =
          List<Chapter>.from(mangaChaptersBox.get(widget.id));
      chapters = tempChapters;
    } else {
      //replace your restFull API here.
      final chapterResponse = await source.chapterListRequest(widget.id);

      chapters = await source.chapterListParse(chapterResponse);
      mangaChaptersBox.put(widget.id, List<Chapter>.from(chapters));
    }

    // chapters.reversed;
    setState(() {
      chapterCount = chapters.length;
      chaptersPassed = chapters;
      started = getChaptersRead(
          '${chapterCount == 0 ? '' : chapters[chapterCount - 1].id}');
      missingChapters = getMissingChaptersCount(chapters);
      // mangaDetails = mangaDetails;
      fetchingData = false;
    });
    updateChapterNumber(widget.id);
    chapterCount == 0
        ? snackbarKey.currentState?.showSnackBar(SnackBar(
            content: Text('No chapters have been found'),
            behavior: SnackBarBehavior.floating,
          ))
        : null;
    return chapters;
  }

  Widget getIcons(String id) {
    if (libraryBox.containsKey(id)) {
      return Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary);
    }
    return Icon(Icons.favorite_outline_outlined);
  }

  void onLibraryPress(String id, String title, String cover, String url,
      DateTime addedAt, String source) {
    if (libraryBox.containsKey(id)) {
      chapterBox.delete(id);
      libraryBox.delete(id);
      return;
    }
    libraryBox.put(id, {
      'id': id,
      'title': title,
      'cover': cover,
      'url': url,
      'addedAt': addedAt,
      'source': source
    });
  }

  void updateChapterNumber(String id) {
    if (libraryBox.containsKey(id)) {
      chapterBox.put(id, chapterCount);
      return;
    }
  }

  int getMissingChaptersCount(List<Chapter> allChapters) {
    List<int> list = [];
    try {
      if (chapterCount != 0) {
        num previous = int.tryParse(allChapters[0].chapter!) ??
            double.parse(allChapters[0].chapter!);
        num current = 0;

        for (var chapter in allChapters) {
          current = chapter.chapter != null
              ? chapter.chapter is int
                  ? int.parse(chapter.chapter!)
                  : double.parse(chapter.chapter!)
              : previous;

          if (previous - current > 1) {
            for (var i = 0; i < previous - 1 - current + 1; i++) {
              list.add(i);
            }
          }
          previous = current;
        }
      }
    } catch (e) {
      snackbarKey.currentState?.showSnackBar(SnackBar(
        content: Text('Unable to parse missing chapters'),
        behavior: SnackBarBehavior.floating,
      ));
    }
    return list.length;
  }

  String getChapterPagesRead(String id, int numPages) {
    var pagesRead = chaptersReadBox.get(widget.id, defaultValue: {});

    // debugPrint('$pagesRead');

    return pagesRead.containsKey(id)
        ? pagesRead[id]['page'] > 1
            ? " | Page: ${pagesRead?[id]?['page']}"
            : ''
        : '';
  }

  bool getChaptersRead(String id) {
    var pagesRead = chaptersReadBox.get(widget.id, defaultValue: {});

    return pagesRead.containsKey(id) ? pagesRead[id]['read'] : false;
  }

  String getChapterDate(String chapterDate) {
    DateTime date = DateTime.parse(chapterDate);

    return DateTimeFormat.format(date, format: ' | j M Y');
  }

  void continueReading(BuildContext context) {
    List<Chapter> allChapters = chaptersPassed;
    List<Chapter> tempChapters = List.from(chaptersPassed);
    Map<dynamic, dynamic> chaptersRead =
        chaptersReadBox.get(widget.id, defaultValue: {});
    int index = 0;
    int pageIndex = chapterCount - 1;
    // debugPrint('$tempChapters');

    // tempChapters.removeWhere((element) => chaptersRead.containsKey(element.id));

    for (var chapter in allChapters) {
      if (chaptersRead.containsKey(chapter.id)) {
        chaptersRead[chapter.id]['read'] ? tempChapters.removeAt(index) : null;
        chaptersRead[chapter.id]['read'] ? pageIndex-- : null;
      }
      index++;
    }
    Chapter last = tempChapters.last;
    // index--;

    if (!chaptersRead.containsKey(last.id)) {
      chaptersRead.addAll({
        last.id: {'read': false, 'page': 0}
      });
      chaptersReadBox.put(widget.id, chaptersRead);
      chaptersRead = chaptersReadBox.get(widget.id);
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return ChapterView(
          id: last.id,
          mangaId: widget.id,
          mangaTitle: widget.title,
          isWebtoon: source.isWebtoon(tags),
          title: last.title,
          chapterCount: chapterCount,
          order: chapterCount - pageIndex,
          chapters: List.from(chaptersPassed),
          index: pageIndex,
          url: last.url ?? "",
          source: widget.source,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // backgroundColor: Colors.transparent,
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(kToolbarHeight),
      //   child: Container(
      //     decoration: BoxDecoration(
      //         image: DecorationImage(
      //             fit: BoxFit.cover,
      //             alignment: Alignment.topCenter,
      //             image: NetworkImage(widget.cover))),
      //     child: AppBar(
      //       backgroundColor: Colors.transparent,
      //     ),
      //   ),
      // ),
      appBar: AppBar(
        title: AnimatedOpacity(
            opacity: position >= 200.0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(widget.title)),
        backgroundColor: _animation.value,
        // expandedHeight: 250,
        // surfaceTintColor: Color(999),
        // iconTheme: IconThemeData(color: Colors.white),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Visibility(
                visible: fetchingData,
                child: LinearProgressIndicator(
                  minHeight: 4.0,
                ))),
        actions: [
          ValueListenableBuilder(
            valueListenable: libraryBox.listenable(),
            builder: (context, value, child) => IconButton(
              onPressed: () {
                onLibraryPress(widget.id, widget.title, widget.cover,
                    widget.url, DateTime.now(), widget.source);
                updateChapterNumber(widget.id);
              },
              icon: getIcons(widget.id),
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return WebView(
                      url: widget.url,
                      title: widget.title,
                    );
                  },
                ));
              },
              icon: Icon(Icons.public_outlined)),
          IconButton(
              onPressed: () {
                Share.share(widget.url);
              },
              icon: Icon(Icons.share_outlined)),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollViewController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            position = scrollInfo.metrics.pixels;
            // debugPrint('$position');
            position > 0.0 && position <= 10.0 ? _controller.forward() : null;
            setState(() {
              isUp = false;
            });
          }
          if (scrollViewController.position.userScrollDirection ==
              ScrollDirection.forward) {
            position = scrollInfo.metrics.pixels;
            // debugPrint('$position');
            if (position <= 5.0) {
              _controller.reverse();
            }
            setState(() {
              isUp = true;
            });
          }
          return true;
        },
        child: Scrollbar(
          radius: Radius.circular(8.0),
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration(seconds: 1), () {
                chapters = getRequest(refresh: true);
              });
            },
            child: CustomScrollView(
              controller: scrollViewController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                FutureBuilder(
                  future: mangaDetails,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return SliverToBoxAdapter();
                    } else {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 0.0, left: 0.0, bottom: 0.0, right: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(children: [
                                Container(
                                  foregroundDecoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: gradientColors)),
                                  width: MediaQuery.of(context).size.width,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.cover,
                                    fit: BoxFit.cover,
                                    height: 320,
                                  ),
                                ),
                                Positioned(
                                  top: MediaQuery.of(context)
                                          .systemGestureInsets
                                          .top +
                                      kToolbarHeight +
                                      8.0,
                                  left: 8.0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                        clipBehavior: Clip.hardEdge,
                                        child: CachedNetworkImage(
                                            imageUrl: widget.cover,
                                            height: 150,
                                            width: 100,
                                            fit: BoxFit.cover),
                                      ),
                                      Flexible(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        1.3 -
                                                    16,
                                                child: Text(
                                                  widget.title,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 5,
                                                  style: const TextStyle(
                                                      fontSize: 22.0),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0,
                                                    right: 8.0,
                                                    top: 8.0),
                                                child: FutureBuilder(
                                                  future: mangaDetails,
                                                  builder: (context,
                                                      AsyncSnapshot snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return Text('');
                                                    } else {
                                                      return Text(
                                                        '${snapshot.data.author}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 8.0,
                                                ),
                                                child: Visibility(
                                                  visible: missingChapters != 0,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.warning,
                                                        size: 16,
                                                      ),
                                                      Text(
                                                          ' Missing ~ $missingChapters chapter(s)'),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Icon(snapshot.data.status ==
                                                    'Completed'
                                                ? Icons.done_all
                                                : Icons.schedule_outlined),
                                            Text('${snapshot.data.status}')
                                          ],
                                        ),
                                        VerticalDivider(
                                          // width: 20,
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                        Column(
                                          children: [
                                            const Icon(Icons.language),
                                            Text(widget.source)
                                          ],
                                        ),
                                        VerticalDivider(
                                          // width: 20,
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                        Column(
                                          children: [
                                            const Icon(
                                                Icons.new_releases_outlined),
                                            Text('${snapshot.data.year}')
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      child: Text(
                                        snapshot.data.synopsis,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        showModalBottomSheet(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0.0)),
                                            backgroundColor:
                                                Colors.black.withOpacity(0.8),
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 16.0),
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  snapshot.data.synopsis,
                                                  softWrap: true,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              );
                                            });
                                      },
                                    ),
                                    // Text('More'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                child: ListView(
                                  padding:
                                      EdgeInsets.only(left: 8.0, right: 6.0),
                                  scrollDirection: Axis.horizontal,
                                  // shrinkWrap: true,
                                  children: tagsWidget,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, left: 8.0, right: 8.0),
                                child: Visibility(
                                  visible: !fetchingData,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('$chapterCount Chapters',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      // FilledButton(
                                      //     onPressed: chapterCount == 0
                                      //         ? null
                                      //         : () {
                                      //             continueReading(context);
                                      //           },
                                      //     child: Row(
                                      //       children: [
                                      //         Padding(
                                      //           padding:
                                      //               const EdgeInsets.only(right: 8.0),
                                      //           child: Icon(Icons.play_arrow),
                                      //         ),
                                      //         started
                                      //             ? Text('Continue')
                                      //             : Text('Start'),
                                      //       ],
                                      //     ))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
                FutureBuilder(
                    future: chapters,
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return SliverToBoxAdapter();
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: false,
                              childCount: chapterCount, (context, index) {
                            return ListTile(
                              // tileColor: Colors.black,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                              // trailing: IconButton(
                              //     onPressed: () {},
                              //     icon: Icon(
                              //         Icons.download_for_offline_outlined)),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: ValueListenableBuilder(
                                      valueListenable:
                                          chaptersReadBox.listenable(),
                                      builder: (context, value, child) => Text(
                                        snapshot.data[index].title,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                            color: getChaptersRead(
                                                    snapshot.data[index].id)
                                                ? settingsBox.get('darkMode',
                                                        defaultValue: false)
                                                    ? Colors.grey[700]
                                                    : Colors.grey[400]
                                                : null),
                                      ),
                                    ),
                                  ),
                                  // Text(
                                  //   '${DateTimeFormat.relative(DateTime.parse(snapshot.data[index].publishAt))} ago',
                                  //   style: TextStyle(
                                  //       color: chaptersRead["chapter"] >=
                                  //               chapterCount - index
                                  //           ? Colors.grey[700]
                                  //           : null),
                                  // ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Text(
                                  //     '${DateTimeFormat.relative(DateTime.parse(snapshot.data[index].publishAt))} ago '),
                                  snapshot.data[index].officialScan == true
                                      ? Icon(
                                          Icons.done_all,
                                          color: getChaptersRead(
                                                  snapshot.data[index].id)
                                              ? settingsBox.get('darkMode',
                                                      defaultValue: false)
                                                  ? Colors.grey[700]
                                                  : Colors.grey[400]
                                              : null,
                                        )
                                      : Text(''),
                                  Text(
                                    ' ${snapshot.data[index].scanGroup == null ? "Unknown group" : snapshot.data[index].scanGroup}',
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: getChaptersRead(
                                                snapshot.data[index].id)
                                            ? settingsBox.get('darkMode',
                                                    defaultValue: false)
                                                ? Colors.grey[700]
                                                : Colors.grey[400]
                                            : null),
                                  ),
                                  Text(getChapterPagesRead(
                                      snapshot.data[index].id,
                                      snapshot.data[index].pages)),
                                  Text(
                                    DateTime.now()
                                                .difference(DateTime.parse(
                                                    snapshot.data[index]
                                                        .readableAt))
                                                .inDays <
                                            7
                                        ? ' | ${DateTimeFormat.relative(
                                            DateTime.parse(snapshot
                                                .data[index].readableAt),
                                          )}'
                                        : getChapterDate(
                                            snapshot.data[index].readableAt),
                                    style: TextStyle(
                                        color: getChaptersRead(
                                                snapshot.data[index].id)
                                            ? settingsBox.get('darkMode',
                                                    defaultValue: false)
                                                ? Colors.grey[700]
                                                : Colors.grey[400]
                                            : null),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (!chaptersRead.containsKey(
                                    '${snapshot.data[index].id}')) {
                                  chaptersRead.addAll({
                                    snapshot.data[index].id: {
                                      'read': false,
                                      'page': 0
                                    }
                                  });
                                  chaptersReadBox.put(widget.id, chaptersRead);
                                  chaptersRead = chaptersReadBox.get(widget.id);
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) {
                                    return ChapterView(
                                      id: snapshot.data[index].id,
                                      mangaId: widget.id,
                                      mangaTitle: widget.title,
                                      isWebtoon: source.isWebtoon(tags),
                                      title: snapshot.data[index].title,
                                      chapterCount: chapterCount,
                                      order: chapterCount - index,
                                      chapters: chaptersPassed,
                                      index: index,
                                      url: snapshot.data[index].url == null
                                          ? ""
                                          : snapshot.data[index].url,
                                      source: widget.source,
                                    );
                                  }),
                                );
                              },
                            );
                          }),
                        );
                      }
                    }),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          // ? FloatingActionButton(
          //     onPressed: () {},
          //     child: Icon(Icons.play_arrow),
          //   )
          Visibility(
        visible: chapterCount != 0,
        child: FloatingActionButton.extended(
          // isExtended: isUp,
          onPressed: () {
            continueReading(context);
          },
          // icon: Icon(Icons.play_arrow),
          label: AnimatedSwitcher(
            duration: Duration(milliseconds: 150),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            ),
            child: !isUp
                ? Icon(Icons.play_arrow)
                : Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: Icon(Icons.play_arrow),
                      ),
                      started ? Text('Continue') : Text('Start'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
