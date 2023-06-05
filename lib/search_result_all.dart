import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/authors.dart';
import 'package:first_app/item_view.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/manga.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/widgets/cached_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'dart:convert' as convert;

import 'package:page_animation_transition/page_animation_transition.dart';

class SearchResultAll extends StatefulWidget {
  const SearchResultAll({super.key, required this.name, required this.sort});

  final String name;
  final String sort;

  @override
  State<SearchResultAll> createState() => _SearchResultState();
}

class Comic {
  final String? id;
  final String? title;
  final List<dynamic>? altTitles;
  final String? cover;
  final String? url;
  final String? synopsis;
  final String? type;
  final String? year;
  final String? status;
  final List<dynamic>? tags;
  final String author;

  Comic({
    required this.id,
    required this.title,
    this.altTitles,
    required this.cover,
    this.url,
    required this.synopsis,
    required this.type,
    required this.year,
    required this.status,
    required this.tags,
    required this.author,
  });
}

class _SearchResultState extends State<SearchResultAll>
    with AutomaticKeepAliveClientMixin {
  // late TextEditingController textController;
  late ScrollController scrollViewController;

  Box settingsBox = Hive.box('settings');

  late var source;
  var comics;
  List<Manga> mangas = [];
  late int itemsPerRow;
  int offset = 0;
  bool fetching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // textController = TextEditingController(text: widget.searchTerm);
    scrollViewController = ScrollController();

    itemsPerRow = settingsBox.get('rowItems', defaultValue: 2);
    source = SourceHelper().getSource(widget.name);
    comics = getRequest(offset);
  }

  @override
  void dispose() {
    // textController.dispose();
    scrollViewController.dispose();
    super.dispose();
  }

  Future<List<Manga>> getRequest(int offset) async {
    //replace your restFull API here.
    late http.Response response;
    List<Manga> comics = [];
    if (widget.sort == 'Latest') {
      response = await source.latestMangaRequest(offset);
      comics = source.latestMangaParse(response);
    } else {
      response = await source.popularMangaRequest(offset);
      comics = source.popularMangaParse(response);
    }

    setState(() {
      mangas += comics;
      fetching = false;
    });
    return mangas;
    // comics = source.popularMangaParse(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        scrolledUnderElevation: 4.0,
        // bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(kTextTabBarHeight),
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //       child: Row(
        //         children: [
        //           ActionChip(
        //             avatar: Icon(Icons.favorite),
        //             label: Text('Popular'),
        //             onPressed: () {},
        //           ),
        //           ActionChip(
        //             avatar: Icon(Icons.new_releases),
        //             label: Text('Latest'),
        //             onPressed: () {},
        //           ),
        //         ],
        //       ),
        //     )),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent.ceil() - 1000.0 &&
              fetching == false) {
            setState(() {
              fetching = true;
              offset++;
            });
            debugPrint('$offset');
            comics = getRequest(offset);
          }
          debugPrint('${notification.metrics.pixels.ceil()}');
          return true;
        },
        child: CustomScrollView(
            controller: scrollViewController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              FutureBuilder(
                future: comics,
                builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return SliverFillRemaining(
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return SliverGrid(
                      // padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: itemsPerRow,
                        childAspectRatio: 0.67,
                        mainAxisSpacing: 2.5,
                        crossAxisSpacing: 2.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return GestureDetector(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0)),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedImage(
                                    cover: snapshot.data[index].cover,
                                  ),
                                  Positioned(
                                    child: Container(
                                      alignment: Alignment.bottomLeft,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                            Colors.black.withOpacity(0.8),
                                            Colors.black.withOpacity(0.0)
                                          ])),
                                      padding: EdgeInsets.all(5.0),
                                      height: 80,
                                      width: MediaQuery.of(context).size.width /
                                              itemsPerRow -
                                          9,
                                      child: Text(
                                        snapshot.data[index].title ??
                                            'Unknown title',
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    bottom: 0.0,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                  PageAnimationTransition(
                                      page: ItemView(
                                        id: snapshot.data[index].id,
                                        title: snapshot.data[index].title ??
                                            'Unknown title',
                                        cover: snapshot.data[index].cover,
                                        url: snapshot.data[index].url,
                                        source: widget.name,
                                        // scrapeDate: snapshot.data[index].scrapeDate,
                                      ),
                                      pageAnimationType:
                                          FadeAnimationTransition()));
                            },
                          );
                        },
                        childCount: snapshot.data.length,
                      ),
                    );
                  }
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20.0,
                ),
              )
            ]),
      ),
      // floatingActionButton: FloatingActionButton(
      //     child: Icon(Icons.filter_list), onPressed: () {}),
    );
  }
}
