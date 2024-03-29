import 'package:first_app/item_view.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/manga.dart';
import 'package:first_app/source/source_helper.dart';
import 'package:first_app/util/page_animation_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchSourceResults extends StatefulWidget {
  const SearchSourceResults(
      {super.key, required this.name, required this.query});

  final String name;
  final String query;

  @override
  State<SearchSourceResults> createState() => _SearchSourceResultsState();
}

class _SearchSourceResultsState extends State<SearchSourceResults> {
  Box settingsBox = Hive.box('settings');

  var mangas;
  int mangaCount = 0;
  late MangaSource source;
  late int itemsPerRow;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemsPerRow = settingsBox.get('rowItems', defaultValue: 2);

    source = SourceHelper().getSource(widget.name);
    mangas = getRequest();
  }

  Future<List<Manga>> getRequest() async {
    final response = await source.searchMangaRequest(1, widget.query, '');

    List<Manga> manga = [];
    manga = await source.searchMangaParse(response);

    setState(() {
      mangaCount = manga.length;
    });

    return manga;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: PageStorageKey<String>(widget.name),
        future: mangas,
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: itemsPerRow,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 2.5,
                  crossAxisSpacing: 2.5,
                ),
                itemCount: mangaCount,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          OptimizedCacheImage(
                            imageUrl: snapshot.data[index].cover,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) => Center(
                              child: Text("Can't load cover"),
                            ),
                            // height: 60.0,
                          ),
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
                                  10,
                              child: Text(
                                snapshot.data[index].title ?? 'Unknown title',
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
                      Navigator.of(context).push(PageAnimationWrapper(
                        key: ValueKey('Manga details'),
                        screen: ItemView(
                          id: snapshot.data[index].id,
                          title: snapshot.data[index].title,
                          cover: snapshot.data[index].cover,
                          url: snapshot.data[index].url,
                          source: widget.name,
                          // scrapeDate: snapshot.data[index].scrapeDate,
                        ),
                      ));
                    },
                  );
                });
          }
        });
  }
}
