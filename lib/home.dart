import 'package:first_app/item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_animation_transition/animations/fade_animation_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Box libraryBox = Hive.box('library');
  Box settingsBox = Hive.box('settings');
  Box chapterBox = Hive.box('chapters');
  Box chaptersReadBox = Hive.box('chaptersRead');
  var libraryItems;
  List<dynamic> mangaChapters = [];
  late int itemsPerRow;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsPerRow = settingsBox.get('rowItems', defaultValue: 2);
    libraryItems = getLibraryItems();
    // debugPrint('$libraryItems');
  }

  List<dynamic> getLibraryItems() {
    List<dynamic> libraryItems = [];

    for (var comic in libraryBox.values) {
      libraryItems.add(comic);
    }

    for (var chapters in chapterBox.values) {
      mangaChapters.add(chapters);
    }
    // mangaChapters = chapterBox.values;

    return libraryItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
        ),
        body: ValueListenableBuilder(
            valueListenable: libraryBox.listenable(),
            builder: ((context, value, child) {
              if (libraryBox.isEmpty) {
                return Center(
                  child: Text("Press 'Add to library' to see it here"),
                );
              } else {
                return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: itemsPerRow,
                      childAspectRatio: 0.7,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 2.5,
                    ),
                    itemCount: libraryBox.length,
                    itemBuilder: ((context, index) {
                      return GestureDetector(
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Hero(
                                tag: libraryItems[index]["cover"],
                                child: Image.network(
                                  'https://uploads.mangadex.org/covers/${libraryItems[index]["id"]}/${libraryItems[index]["cover"]}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Text("Can't load cover"),
                                  ),
                                  // height: 60.0,
                                ),
                              ),
                              Positioned(
                                  top: 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.blue[400],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0))),
                                    margin: EdgeInsets.all(8.0),
                                    padding: EdgeInsets.all(3.0),
                                    // clipBehavior: Clip.hardEdge,
                                    // color: Colors.blue,
                                    child: Text(
                                      '${mangaChapters[index] - chaptersReadBox.get(libraryItems[index]["id"], defaultValue: {
                                                'chapter': 0,
                                                'page': 0
                                              })["chapter"]}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )),
                              Positioned(
                                child: Container(
                                  alignment: Alignment.bottomLeft,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.black.withOpacity(0.0)
                                      ])),
                                  padding: EdgeInsets.all(5.0),
                                  height: 80,
                                  width: MediaQuery.of(context).size.width /
                                          itemsPerRow -
                                      14,
                                  child: Text(
                                    libraryItems[index]["title"],
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
                          Navigator.of(context).push(PageAnimationTransition(
                              page: ItemView(
                                id: libraryItems[index]["id"],
                                title: libraryItems[index]["title"],
                                cover: libraryItems[index]["cover"],
                                url: libraryItems[index]["title"],
                                synopsis:
                                    libraryItems[index]["synopsis"] == null
                                        ? "No description"
                                        : libraryItems[index]["synopsis"],
                                type: libraryItems[index]["type"],
                                year: libraryItems[index]["year"],
                                status: libraryItems[index]["status"],
                                tags: libraryItems[index]["tags"],
                                author: libraryItems[index]["author"],
                                // scrapeDate: snapshot.data[index].scrapeDate,
                              ),
                              pageAnimationType: FadeAnimationTransition()));
                        },
                        onLongPress: () {
                          chapterBox.deleteAt(index);
                          libraryBox.deleteAt(index);
                        },
                      );
                    }));
              }
            })));
  }
}
