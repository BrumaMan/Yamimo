import 'dart:ui';

import 'package:first_app/chapter_view.dart';
import 'package:first_app/search_result.dart';
import 'package:first_app/util/theme.dart';
import 'package:first_app/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ItemView extends StatefulWidget {
  const ItemView({
    super.key,
    required this.id,
    required this.title,
    required this.cover,
    required this.url,
    required this.synopsis,
    required this.type,
    required this.year,
    required this.status,
    required this.tags,
    required this.author,
    // required this.scrapeDate,
  });

  final String id;
  final String title;
  final String cover;
  final String url;
  final String synopsis;
  final String type;
  final String? year;
  final String? status;
  final List<dynamic>? tags;
  final String author;
  // final String scrapeDate;

  @override
  State<ItemView> createState() => _ItemViewState();
}

class Chapter {
  final String id;
  final String? title;
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

class _ItemViewState extends State<ItemView> with TickerProviderStateMixin {
  late ScrollController scrollViewController;
  late TabController _tabController;
  Box libraryBox = Hive.box('library');
  Box chapterBox = Hive.box('chapters');
  Box chaptersReadBox = Hive.box('chaptersRead');
  List<Widget> tags = [];
  var chaptersRead;
  var chapters;
  var nextChapters;
  var chaptersPassed;
  int chapterCount = 0;
  double position = 0.0;
  bool isUp = true;
  bool started = false;

  double sensitivityFactor = 20.0;

  @override
  void initState() {
    super.initState();
    chaptersRead = chaptersReadBox.get(widget.id, defaultValue: {});
    if (chaptersRead['chapter'] != null) {
      chaptersReadBox.delete(widget.id);
      chaptersRead = chaptersReadBox.get(widget.id, defaultValue: {});
    }
    getTags();
    scrollViewController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
    // textController = TextEditingController(text: widget.searchTerm);
    chapters = getRequest();
    // nextChapters = chapters as List<Chapter>;
    // debugPrint('${scrollViewController.positions}');
  }

  @override
  void dispose() {
    // textController.dispose();
    scrollViewController.dispose();
    super.dispose();
  }

  void getTags() {
    // widget.tags!
    //     .removeWhere((element) => element["attributes"]["group"] != 'genre');
    for (var tag in widget.tags!) {
      tags.add(Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(tag["attributes"]["name"]["en"],
            style: TextStyle(
              fontSize: 12,
            )),
      ));
    }
  }

  Future<List<Chapter>> getRequest() async {
    //replace your restFull API here.
    Uri url = Uri.https("api.mangadex.org", "/manga/${widget.id}/feed", {
      'translatedLanguage[]': "en",
      'includes[]': 'scanlation_group',
      'limit': '450'
    });
    final response = await http.get(url);

    var responseData = convert.jsonDecode(response.body)["data"];

    // print(responseData);

    //Creating a list to store input data;
    List<Chapter> chapters = [];
    int index = 0;
    for (var singleComic in responseData) {
      Chapter chapter = Chapter(
        id: singleComic["id"],
        title: singleComic["attributes"]["title"],
        volume: singleComic["attributes"]["volume"],
        chapter: singleComic["attributes"]["chapter"],
        pages: singleComic["attributes"]["pages"],
        url: singleComic["attributes"]["externalUrl"],
        publishAt: singleComic["attributes"]["publishAt"],
        readableAt: singleComic["attributes"]["readableAt"],
        scanGroup: singleComic["relationships"]?[0]?["attributes"]?["name"],
        officialScan: singleComic["relationships"]?[0]?["attributes"]
            ?["official"],
      );

      //Adding user to the list.
      chapters.add(chapter);
      index + 1;
    }
    chapters.sort((a, b) => b.readableAt!.compareTo(a.readableAt!));
    // chapters.reversed;
    setState(() {
      chapterCount = chapters.length;
      chaptersPassed = chapters;
      started = getChaptersRead('${chapters[chapters.length - 1].id}');
    });
    updateChapterNumber(widget.id);
    return chapters;
  }

  Widget getIcons(String id) {
    if (libraryBox.containsKey(id)) {
      return Icon(Icons.favorite, color: Colors.blue[300]);
    }
    return Icon(Icons.favorite_outline_outlined);
  }

  void onLibraryPress(
      String id,
      String title,
      String cover,
      String synopsis,
      String type,
      String? year,
      String? status,
      List<dynamic>? tags,
      String author) {
    if (libraryBox.containsKey(id)) {
      chapterBox.delete(id);
      libraryBox.delete(id);
      return;
    }
    libraryBox.put(id, {
      'id': id,
      'title': title,
      'cover': cover,
      'synopsis': synopsis,
      'type': type,
      'year': year,
      'status': status,
      'tags': tags,
      'author': author,
    });
  }

  void updateChapterNumber(String id) {
    if (libraryBox.containsKey(id)) {
      int chapterNumber = chapterBox.get(id, defaultValue: chapterCount);
      int newChaptersNum = chapterNumber - chapterCount;
      chapterBox.put(id, chapterCount);
      return;
    }
  }

  String getChapterPagesRead(String id, int numPages) {
    var pagesRead = chaptersReadBox.get(widget.id, defaultValue: {});

    // debugPrint('$pagesRead');

    return pagesRead.containsKey(id)
        ? pagesRead[id]['page'] > 1 && pagesRead[id]['page'] < numPages
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
    Map<dynamic, dynamic> chaptersRead = chaptersReadBox.get(widget.id);
    int index = 0;
    int pageIndex = chapterCount - 1;

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
          title: last.title == null
              ? last.volume == null
                  ? "chapter ${chapterCount - pageIndex}"
                  : "Vol. ${last.volume} ch. ${chapterCount - pageIndex}"
              : last.volume == null
                  ? "ch. ${chapterCount - pageIndex} - ${last.title}"
                  : "Vol. ${last.volume} ch. ${chapterCount - pageIndex} - ${last.title}",
          chapterCount: chapterCount,
          order: chapterCount - pageIndex,
          chapters: List.from(chaptersPassed),
          index: pageIndex,
          url: last.url ?? "",
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(kToolbarHeight),
      //   child: Container(
      //     decoration: BoxDecoration(
      //         image: DecorationImage(
      //             fit: BoxFit.cover,
      //             alignment: Alignment.topCenter,
      //             image: NetworkImage(
      //                 'https://uploads.mangadex.org/covers/${widget.id}/${widget.cover}'))),
      //     child: AppBar(
      //       backgroundColor: Colors.transparent,
      //     ),
      //   ),
      // ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollViewController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            position = scrollInfo.metrics.pixels;
            setState(() {
              isUp = false;
            });
          }
          if (scrollViewController.position.userScrollDirection ==
              ScrollDirection.forward) {
            position = scrollInfo.metrics.pixels;
            setState(() {
              isUp = true;
            });
          }
          return true;
        },
        child: Scrollbar(
          radius: Radius.circular(8.0),
          child: CustomScrollView(
            controller: scrollViewController,
            slivers: [
              SliverAppBar(
                // title: Text(widget.title),
                pinned: true,
                // surfaceTintColor: Color(999),
                // iconTheme: IconThemeData(color: Colors.white),
                actions: [
                  // IconButton(
                  //     onPressed: () {
                  //       showModalBottomSheet(
                  //           context: context,
                  //           builder: ((context) {
                  //             return Center(
                  //                 child: ElevatedButton(
                  //                     child: Text('Close'),
                  //                     onPressed: () {
                  //                       Navigator.pop(context);
                  //                     }));
                  //           }));
                  //     },
                  //     icon: const Icon(Icons.filter_list_outlined))
                  ValueListenableBuilder(
                    valueListenable: libraryBox.listenable(),
                    builder: (context, value, child) => IconButton(
                      onPressed: () {
                        onLibraryPress(
                            widget.id,
                            widget.title,
                            widget.cover,
                            widget.synopsis,
                            widget.type,
                            widget.year,
                            widget.status,
                            widget.tags,
                            widget.author);
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
                              url:
                                  'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}',
                              title: widget.title,
                            );
                          },
                        ));
                      },
                      icon: Icon(Icons.public_outlined)),
                  IconButton(
                      onPressed: () {
                        Share.share(
                            'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}');
                      },
                      icon: Icon(Icons.share_outlined)),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 8.0, bottom: 0.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0)),
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(
                                imageUrl:
                                    'https://uploads.mangadex.org/covers/${widget.id}/${widget.cover}',
                                height: 150,
                                width: 100,
                                fit: BoxFit.cover),
                          ),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    width: MediaQuery.of(context).size.width /
                                            1.3 -
                                        16,
                                    child: Text(
                                      widget.title,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                      style: const TextStyle(fontSize: 22.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0, top: 8.0),
                                    child: Text(
                                      '${widget.author}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       // MaterialButton(
                                  //       //     shape: RoundedRectangleBorder(
                                  //       //         borderRadius: BorderRadius.all(
                                  //       //             Radius.circular(8.0))),
                                  //       //     color: Colors.blue[400],
                                  //       //     onPressed: () {
                                  //       //       chaptersReadBox.put(widget.id, {
                                  //       //         'chapter':
                                  //       //             chaptersRead["chapter"] + 1,
                                  //       //         'page': 0
                                  //       //       });
                                  //       //       chaptersRead =
                                  //       //           chaptersReadBox.get(widget.id);
                                  //       //       Navigator.of(context).push(
                                  //       //         MaterialPageRoute(
                                  //       //             builder: (context) {
                                  //       //           return ChapterView(
                                  //       //             id: nextChapters[
                                  //       //                     chapterCount -
                                  //       //                         chaptersRead[
                                  //       //                             "chapter"]]
                                  //       //                 .id,
                                  //       //             title: nextChapters[chapterCount -
                                  //       //                             chaptersRead[
                                  //       //                                 "chapter"]]
                                  //       //                         .title ==
                                  //       //                     null
                                  //       //                 ? nextChapters[chapterCount -
                                  //       //                                 chaptersRead[
                                  //       //                                     "chapter"]]
                                  //       //                             .volume ==
                                  //       //                         null
                                  //       //                     ? "chapter ${chaptersRead['chapter']}"
                                  //       //                     : "Vol. ${nextChapters[chapterCount - chaptersRead["chapter"]].volume} ch. ${chaptersRead['chapter']}"
                                  //       //                 : nextChapters[chapterCount -
                                  //       //                                 chaptersRead[
                                  //       //                                     "chapter"]]
                                  //       //                             .volume ==
                                  //       //                         null
                                  //       //                     ? "ch. ${chaptersRead['chapter']} - ${nextChapters[chapterCount - chaptersRead["chapter"]].title}"
                                  //       //                     : "Vol. ${nextChapters[chapterCount - chaptersRead["chapter"]].volume} ch. ${chaptersRead['chapter']} - ${nextChapters[chapterCount - chaptersRead["chapter"]].title}",
                                  //       //             chapterCount: chapterCount,
                                  //       //             order:
                                  //       //                 chaptersRead['chapter'],
                                  //       //             chapters: chaptersPassed,
                                  //       //             index:
                                  //       //                 chaptersRead['chapter'],
                                  //       //             url: nextChapters[chapterCount -
                                  //       //                             chaptersRead[
                                  //       //                                 "chapter"]]
                                  //       //                         .url ==
                                  //       //                     null
                                  //       //                 ? ""
                                  //       //                 : nextChapters[
                                  //       //                         chapterCount -
                                  //       //                             chaptersRead[
                                  //       //                                 "chapter"]]
                                  //       //                     .url,
                                  //       //           );
                                  //       //         }),
                                  //       //       );
                                  //       //     },
                                  //       //     child: Text(
                                  //       //         chaptersRead["chapter"] == 0
                                  //       //             ? 'Read'
                                  //       //             : 'Continue')),
                                  //       // ValueListenableBuilder(
                                  //       //   valueListenable:
                                  //       //       libraryBox.listenable(),
                                  //       //   builder: (context, value, child) =>
                                  //       //       IconButton(
                                  //       //     onPressed: () {
                                  //       //       onLibraryPress(
                                  //       //           widget.id,
                                  //       //           widget.title,
                                  //       //           widget.cover,
                                  //       //           widget.synopsis,
                                  //       //           widget.type,
                                  //       //           widget.year,
                                  //       //           widget.status,
                                  //       //           widget.tags,
                                  //       //           widget.author);
                                  //       //       updateChapterNumber(widget.id);
                                  //       //     },
                                  //       //     icon: getIcons(widget.id),
                                  //       //   ),
                                  //       // ),
                                  //       // IconButton(
                                  //       //     onPressed: () {
                                  //       //       Navigator.of(context)
                                  //       //           .push(MaterialPageRoute(
                                  //       //         builder: (context) {
                                  //       //           return WebView(
                                  //       //             url:
                                  //       //                 'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}',
                                  //       //             title: widget.title,
                                  //       //           );
                                  //       //         },
                                  //       //       ));
                                  //       //     },
                                  //       //     icon: Icon(Icons.public_outlined)),
                                  //       // IconButton(
                                  //       //     onPressed: () {
                                  //       //       Share.share(
                                  //       //           'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}');
                                  //       //     },
                                  //       //     icon: Icon(Icons.share_outlined)),
                                  //     ],
                                  //   ),
                                  // )
                                ]),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: IntrinsicHeight(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Icon(widget.status == 'completed'
                                        ? Icons.done_all
                                        : Icons.schedule_outlined),
                                    Text('${widget.status}')
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
                                    Text('Mangadex')
                                  ],
                                ),
                                VerticalDivider(
                                  // width: 20,
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                Column(
                                  children: [
                                    const Icon(Icons.new_releases_outlined),
                                    Text('${widget.year}')
                                  ],
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Text(
                                widget.synopsis,
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
                                        margin: EdgeInsets.only(bottom: 16.0),
                                        padding: EdgeInsets.all(12.0),
                                        child: Text(
                                          widget.synopsis,
                                          softWrap: true,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    });
                              },
                            ),
                            // Text('More'),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 0.0,
                        children: tags,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$chapterCount Chapters',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            FilledButton(
                                onPressed: () {
                                  continueReading(context);
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.play_arrow),
                                    ),
                                    started ? Text('Continue') : Text('Start'),
                                  ],
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              FutureBuilder(
                  future: chapters,
                  builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
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
                            // leading: Card(
                            //   clipBehavior: Clip.hardEdge,
                            //   child: Image.network(
                            //     snapshot.data[index].content[0],
                            //     fit: BoxFit.cover,
                            //     width: 50.0,
                            //   ),
                            // ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable:
                                        chaptersReadBox.listenable(),
                                    builder: (context, value, child) => Text(
                                      snapshot.data[index].title == null
                                          ? snapshot.data[index].volume == null
                                              ? "ch. ${snapshot.data[index].chapter}"
                                              : "Vol. ${snapshot.data[index].volume} ch. ${snapshot.data[index].chapter}"
                                          : snapshot.data[index].volume == null
                                              ? "ch. ${snapshot.data[index].chapter} - ${snapshot.data[index].title}"
                                              : "Vol. ${snapshot.data[index].volume} ch. ${snapshot.data[index].chapter} - ${snapshot.data[index].title}",
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                          color: getChaptersRead(
                                                  snapshot.data[index].id)
                                              ? settingsBox.get('darkMode',
                                                      defaultValue: false)
                                                  ? Colors.grey[700]
                                                  : Colors.grey[500]
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
                                                : Colors.grey[500]
                                            : null,
                                      )
                                    : Text(''),
                                Text(
                                  ' ${snapshot.data[index].scanGroup == null ? "Unknown group" : snapshot.data[index].scanGroup}',
                                  style: TextStyle(
                                      color: getChaptersRead(
                                              snapshot.data[index].id)
                                          ? settingsBox.get('darkMode',
                                                  defaultValue: false)
                                              ? Colors.grey[700]
                                              : Colors.grey[500]
                                          : null),
                                ),
                                Text(getChapterPagesRead(
                                    snapshot.data[index].id,
                                    snapshot.data[index].pages)),
                                Text(
                                  DateTime.now()
                                              .difference(DateTime.parse(
                                                  snapshot
                                                      .data[index].readableAt))
                                              .inDays <=
                                          7
                                      ? ' | ${DateTimeFormat.relative(
                                          DateTime.parse(
                                              snapshot.data[index].readableAt),
                                        )}'
                                      : getChapterDate(
                                          snapshot.data[index].readableAt),
                                  style: TextStyle(
                                      color: getChaptersRead(
                                              snapshot.data[index].id)
                                          ? settingsBox.get('darkMode',
                                                  defaultValue: false)
                                              ? Colors.grey[700]
                                              : Colors.grey[500]
                                          : null),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (!chaptersRead
                                  .containsKey('${snapshot.data[index].id}')) {
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
                                    title: snapshot.data[index].title == null
                                        ? snapshot.data[index].volume == null
                                            ? "chapter ${chapterCount - index}"
                                            : "Vol. ${snapshot.data[index].volume} ch. ${chapterCount - index}"
                                        : snapshot.data[index].volume == null
                                            ? "ch. ${chapterCount - index} - ${snapshot.data[index].title}"
                                            : "Vol. ${snapshot.data[index].volume} ch. ${chapterCount - index} - ${snapshot.data[index].title}",
                                    chapterCount: chapterCount,
                                    order: chapterCount - index,
                                    chapters: chaptersPassed,
                                    index: index,
                                    url: snapshot.data[index].url == null
                                        ? ""
                                        : snapshot.data[index].url,
                                  );
                                }),
                              );
                            },
                          );
                        }),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
      // floatingActionButton:
      //     // ? FloatingActionButton(
      //     //     onPressed: () {},
      //     //     child: Icon(Icons.play_arrow),
      //     //   )
      //     AnimatedSize(
      //   alignment: Alignment.center,
      //   clipBehavior: Clip.none,
      //   duration: Duration(milliseconds: 300),
      //   curve: Curves.fastLinearToSlowEaseIn,
      //   child: FloatingActionButton.extended(
      //     isExtended: isUp,
      //     onPressed: (() {}),
      //     label: const Text('Start'),
      //     icon: Icon(Icons.play_arrow),
      //   ),
      // ),
    );
  }
}
