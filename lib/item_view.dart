import 'dart:ui';

import 'package:first_app/chapter_view.dart';
import 'package:first_app/search_result.dart';
import 'package:first_app/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:date_time_format/date_time_format.dart';
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
  final String? id;
  final String? title;
  final String? volume;
  final String? chapter;
  final int? pages;
  final String? url;
  final String? publishAt;
  final String? readableAt;
  final String? scanGroup;
  // final String? prev;

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
    // required this.prev,
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

  double sensitivityFactor = 20.0;

  @override
  void initState() {
    super.initState();
    chaptersRead =
        chaptersReadBox.get(widget.id, defaultValue: {'chapter': 0, 'page': 0});
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
    widget.tags!
        .removeWhere((element) => element["attributes"]["group"] != 'genre');
    for (var tag in widget.tags!) {
      tags.add(Container(
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.8),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(tag["attributes"]["name"]["en"],
            style: TextStyle(fontSize: 12, color: Colors.white)),
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
          chapter: singleComic["attributes"]["Chapter"],
          pages: singleComic["attributes"]["pages"],
          url: singleComic["attributes"]["externalUrl"],
          publishAt: singleComic["attributes"]["publishAt"],
          readableAt: singleComic["attributes"]["readableAt"],
          scanGroup: singleComic["relationships"]?[0]?["attributes"]?["name"]
          // prev: singleComic["ChapterPrevSlug"],
          );

      //Adding user to the list.
      chapters.add(chapter);
      index + 1;
    }
    chapters.sort((a, b) => b.publishAt!.compareTo(a.publishAt!));
    // chapters.reversed;
    setState(() {
      chapterCount = chapters.length;
      chaptersPassed = chapters;
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
      chapterBox.put(id, chapterNumber + newChaptersNum);
      return;
    }
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
                iconTheme: IconThemeData(color: Colors.white),
                expandedHeight: 230.0 +
                    kToolbarHeight +
                    MediaQuery.of(context).viewPadding.top,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  // title: Text(widget.title),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://uploads.mangadex.org/covers/${widget.id}/${widget.cover}',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.4)
                            ])),
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: kToolbarHeight +
                                  MediaQuery.of(context).viewPadding.top),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'By ${widget.author}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: GestureDetector(
                                  child: Text(
                                    widget.synopsis,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                        backgroundColor:
                                            Colors.black.withOpacity(0.8),
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            margin:
                                                EdgeInsets.only(bottom: 16.0),
                                            padding: EdgeInsets.all(12.0),
                                            child: Text(
                                              widget.synopsis,
                                              softWrap: true,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        });
                                  },
                                ),
                              ),
                              Text(
                                '${widget.status} · ${widget.year}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Wrap(
                                spacing: 3.0,
                                runSpacing: 5.0,
                                children: tags,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row(
                      //   // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     // Card(
                      //     //   clipBehavior: Clip.hardEdge,
                      //     //   child: Image.network(
                      //     //       'https://uploads.mangadex.org/covers/${widget.id}/${widget.cover}',
                      //     //       height: 150,
                      //     //       width: 100,
                      //     //       fit: BoxFit.cover),
                      //     // ),
                      //     Expanded(
                      //       child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             // Container(
                      //             //   padding: const EdgeInsets.only(left: 8.0),
                      //             //   width: MediaQuery.of(context).size.width /
                      //             //           1.3 -
                      //             //       16,
                      //             //   child: Text(
                      //             //     widget.title,
                      //             //     softWrap: true,
                      //             //     overflow: TextOverflow.ellipsis,
                      //             //     maxLines: 5,
                      //             //     style: const TextStyle(fontSize: 18.0),
                      //             //   ),
                      //             // ),
                      //             // Padding(
                      //             //   padding: const EdgeInsets.only(
                      //             //       left: 8.0, right: 8.0, top: 8.0),
                      //             //   child: Text('By ${widget.author}'),
                      //             // ),
                      //             // Padding(
                      //             //   padding: const EdgeInsets.symmetric(
                      //             //       horizontal: 8.0, vertical: 8.0),
                      //             //   child: Text(
                      //             //     '${widget.status} · ${widget.year}',
                      //             //     style:
                      //             //         const TextStyle(color: Colors.grey),
                      //             //   ),
                      //             // ),
                      //             Padding(
                      //               padding: const EdgeInsets.all(8.0),
                      //               child: Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceBetween,
                      //                 children: [
                      //                   // MaterialButton(
                      //                   //     shape: RoundedRectangleBorder(
                      //                   //         borderRadius: BorderRadius.all(
                      //                   //             Radius.circular(8.0))),
                      //                   //     color: Colors.blue[400],
                      //                   //     onPressed: () {
                      //                   //       chaptersReadBox.put(widget.id, {
                      //                   //         'chapter':
                      //                   //             chaptersRead["chapter"] + 1,
                      //                   //         'page': 0
                      //                   //       });
                      //                   //       chaptersRead =
                      //                   //           chaptersReadBox.get(widget.id);
                      //                   //       Navigator.of(context).push(
                      //                   //         MaterialPageRoute(
                      //                   //             builder: (context) {
                      //                   //           return ChapterView(
                      //                   //             id: nextChapters[
                      //                   //                     chapterCount -
                      //                   //                         chaptersRead[
                      //                   //                             "chapter"]]
                      //                   //                 .id,
                      //                   //             title: nextChapters[chapterCount -
                      //                   //                             chaptersRead[
                      //                   //                                 "chapter"]]
                      //                   //                         .title ==
                      //                   //                     null
                      //                   //                 ? nextChapters[chapterCount -
                      //                   //                                 chaptersRead[
                      //                   //                                     "chapter"]]
                      //                   //                             .volume ==
                      //                   //                         null
                      //                   //                     ? "chapter ${chaptersRead['chapter']}"
                      //                   //                     : "Vol. ${nextChapters[chapterCount - chaptersRead["chapter"]].volume} ch. ${chaptersRead['chapter']}"
                      //                   //                 : nextChapters[chapterCount -
                      //                   //                                 chaptersRead[
                      //                   //                                     "chapter"]]
                      //                   //                             .volume ==
                      //                   //                         null
                      //                   //                     ? "ch. ${chaptersRead['chapter']} - ${nextChapters[chapterCount - chaptersRead["chapter"]].title}"
                      //                   //                     : "Vol. ${nextChapters[chapterCount - chaptersRead["chapter"]].volume} ch. ${chaptersRead['chapter']} - ${nextChapters[chapterCount - chaptersRead["chapter"]].title}",
                      //                   //             chapterCount: chapterCount,
                      //                   //             order:
                      //                   //                 chaptersRead['chapter'],
                      //                   //             chapters: chaptersPassed,
                      //                   //             index:
                      //                   //                 chaptersRead['chapter'],
                      //                   //             url: nextChapters[chapterCount -
                      //                   //                             chaptersRead[
                      //                   //                                 "chapter"]]
                      //                   //                         .url ==
                      //                   //                     null
                      //                   //                 ? ""
                      //                   //                 : nextChapters[
                      //                   //                         chapterCount -
                      //                   //                             chaptersRead[
                      //                   //                                 "chapter"]]
                      //                   //                     .url,
                      //                   //           );
                      //                   //         }),
                      //                   //       );
                      //                   //     },
                      //                   //     child: Text(
                      //                   //         chaptersRead["chapter"] == 0
                      //                   //             ? 'Read'
                      //                   //             : 'Continue')),
                      //                   ValueListenableBuilder(
                      //                     valueListenable:
                      //                         libraryBox.listenable(),
                      //                     builder: (context, value, child) =>
                      //                         IconButton(
                      //                       onPressed: () {
                      //                         onLibraryPress(
                      //                             widget.id,
                      //                             widget.title,
                      //                             widget.cover,
                      //                             widget.synopsis,
                      //                             widget.type,
                      //                             widget.year,
                      //                             widget.status,
                      //                             widget.tags,
                      //                             widget.author);
                      //                         updateChapterNumber(widget.id);
                      //                       },
                      //                       icon: getIcons(widget.id),
                      //                     ),
                      //                   ),
                      //                   IconButton(
                      //                       onPressed: () {
                      //                         Navigator.of(context)
                      //                             .push(MaterialPageRoute(
                      //                           builder: (context) {
                      //                             return WebView(
                      //                               url:
                      //                                   'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}',
                      //                               title: widget.title,
                      //                             );
                      //                           },
                      //                         ));
                      //                       },
                      //                       icon: Icon(Icons.public_outlined)),
                      //                   IconButton(
                      //                       onPressed: () {
                      //                         Share.share(
                      //                             'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}');
                      //                       },
                      //                       icon: Icon(Icons.share_outlined)),
                      //                 ],
                      //               ),
                      //             )
                      //           ]),
                      //     ),
                      //   ],
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(top: 8.0),
                      //   child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //       children: [
                      //         ValueListenableBuilder(
                      //             valueListenable: libraryBox.listenable(),
                      //             builder: (context, value, child) {
                      //               return GestureDetector(
                      //                 behavior: HitTestBehavior.opaque,
                      //                 child: Column(
                      //                   children: [
                      //                     getIcons(widget.id),
                      //                     libraryBox.containsKey(widget.id)
                      //                         ? Text(
                      //                             'In library',
                      //                             style: TextStyle(
                      //                                 color: Colors.blue[300]),
                      //                           )
                      //                         : const Text('Add to library')
                      //                   ],
                      //                 ),
                      //                 onTap: () {
                      //                   debugPrint('here');
                      //                   onLibraryPress(
                      //                       widget.id,
                      //                       widget.title,
                      //                       widget.cover,
                      //                       widget.synopsis,
                      //                       widget.type,
                      //                       widget.year,
                      //                       widget.status,
                      //                       widget.tags);
                      //                   updateChapterNumber(widget.id);
                      //                 },
                      //               );
                      //             }),
                      //         GestureDetector(
                      //           child: Column(
                      //             children: [
                      //               const Icon(Icons.public_outlined),
                      //               const Text('Webview')
                      //             ],
                      //           ),
                      //           onTap: () {
                      //             Navigator.of(context).push(MaterialPageRoute(
                      //               builder: (context) {
                      //                 return WebView(
                      //                   url:
                      //                       'https://mangadex.org/title/${widget.id}/${widget.title.toLowerCase()}',
                      //                   title: widget.title,
                      //                 );
                      //               },
                      //             ));
                      //           },
                      //         ),
                      //       ]),
                      // ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   decoration: BoxDecoration(
                      //       color: Colors.white.withOpacity(0.2),
                      //       borderRadius:
                      //           BorderRadius.all(Radius.circular(5.0))),
                      //   margin: EdgeInsets.symmetric(vertical: 8.0),
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'Synopsis',
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.bold, fontSize: 18.0),
                      //       ),
                      //       GestureDetector(
                      //         child: Text(
                      //           widget.synopsis,
                      //           maxLines: 3,
                      //           overflow: TextOverflow.ellipsis,
                      //         ),
                      //         onTap: () {
                      //           showModalBottomSheet(
                      //               backgroundColor:
                      //                   Colors.black.withOpacity(0.8),
                      //               context: context,
                      //               builder: (context) {
                      //                 return Container(
                      //                   margin: EdgeInsets.only(bottom: 16.0),
                      //                   padding: EdgeInsets.all(12.0),
                      //                   child: Text(
                      //                     widget.synopsis,
                      //                     softWrap: true,
                      //                   ),
                      //                 );
                      //               });
                      //         },
                      //       ),
                      //       // Text('More'),
                      //     ],
                      //   ),
                      // ),
                      // Wrap(
                      //   spacing: 5.0,
                      //   runSpacing: 5.0,
                      //   children: tags,
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Chapter Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text('Uploaded',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
                                              ? "chapter ${chapterCount - index}"
                                              : "Vol. ${snapshot.data[index].volume} ch. ${chapterCount - index}"
                                          : snapshot.data[index].volume == null
                                              ? "ch. ${chapterCount - index} - ${snapshot.data[index].title}"
                                              : "Vol. ${snapshot.data[index].volume} ch. ${chapterCount - index} - ${snapshot.data[index].title}",
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                          color: chaptersRead["chapter"] >=
                                                  chapterCount - index
                                              ? Colors.grey[700]
                                              : null),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${DateTimeFormat.relative(DateTime.parse(snapshot.data[index].publishAt))} ago',
                                  style: TextStyle(
                                      color: chaptersRead["chapter"] >=
                                              chapterCount - index
                                          ? Colors.grey[700]
                                          : null),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                // Text(
                                //     '${DateTimeFormat.relative(DateTime.parse(snapshot.data[index].publishAt))} ago '),
                                // Icon(
                                //   Icons.person_outline,
                                //   color: chaptersRead["chapter"] >=
                                //           chapterCount - index
                                //       ? Colors.grey[700]
                                //       : null,
                                // ),
                                Text(
                                  '${snapshot.data[index].scanGroup == null ? "Unknown group" : snapshot.data[index].scanGroup}',
                                  style: TextStyle(
                                      color: chaptersRead["chapter"] >=
                                              chapterCount - index
                                          ? Colors.grey[700]
                                          : null),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (chapterCount - index >
                                  chaptersRead["chapter"]) {
                                chaptersReadBox.put(widget.id, {
                                  'chapter': chapterCount - index,
                                  'page': 0
                                });
                                chaptersRead = chaptersReadBox.get(widget.id);
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return ChapterView(
                                    id: snapshot.data[index].id,
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
