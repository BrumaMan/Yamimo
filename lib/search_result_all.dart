import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/authors.dart';
import 'package:first_app/item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SearchResultAll extends StatefulWidget {
  const SearchResultAll({super.key, required this.genre, this.author});

  final String? genre;
  final Author? author;

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

class _SearchResultState extends State<SearchResultAll> {
  // late TextEditingController textController;
  var comics;

  @override
  void initState() {
    super.initState();
    // textController = TextEditingController(text: widget.searchTerm);
    comics = getRequest();
  }

  @override
  void dispose() {
    // textController.dispose();
    super.dispose();
  }

  Future<List<Comic>> getRequest() async {
    //replace your restFull API here.
    Uri url = Uri.https(
        "api.mangadex.org",
        "/manga",
        widget.genre == ''
            ? widget.author?.name == ''
                ? {
                    'includes[]': ['cover_art', 'author'],
                    // 'includes[]': 'author',
                    'limit': '100'
                  }
                : {
                    'authors[]': widget.author?.id,
                    'includes[]': ['cover_art', 'author'],
                    // 'includes[]': 'author',
                    'limit': '100'
                  }
            : {
                'includedTags[]': widget.genre,
                'includes[]': ['cover_art', 'author'],
                // 'includes[]': 'author',
                'limit': '100'
              });
    final response = await http.get(url);

    var responseData = convert.jsonDecode(response.body)["data"];

    // print(responseData);

    //Creating a list to store input data;
    List<Comic> comics = [];
    int index = 0;
    for (var singleComic in responseData) {
      Comic comic = Comic(
        id: singleComic["id"],
        title: singleComic["attributes"]["title"]["en"],
        altTitles: singleComic["attributes"]["altTitles"],
        cover: singleComic["relationships"][singleComic["relationships"]
                .indexWhere((element) => element["type"] == "cover_art")]
            ["attributes"]["fileName"],
        url: singleComic["attributes"]["title"]["en"],
        synopsis: singleComic["attributes"]["description"]["en"],
        type: singleComic["type"],
        year: '${singleComic["attributes"]["year"]}',
        status: singleComic["attributes"]["status"],
        tags: singleComic["attributes"]["tags"],
        author: singleComic["relationships"][singleComic["relationships"]
                .indexWhere((element) => element["type"] == "author")]
            ["attributes"]["name"],
      );
      // debugPrint('${comic.author}');
      //Adding user to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.genre == ''
          ? widget.author?.name == ''
              ? AppBar(
                  title: const Text('Manga List'),
                  scrolledUnderElevation: 4.0,
                )
              : AppBar(
                  title: Text('${widget.author?.name}'),
                  scrolledUnderElevation: 4.0,
                )
          : null,
      body: FutureBuilder(
        future: comics,
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 2.5,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (ctx, index) {
                return GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              'https://uploads.mangadex.org/covers/${snapshot.data[index].id}/${snapshot.data[index].cover}',
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
                            width: MediaQuery.of(context).size.width / 2 - 14,
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
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return ItemView(
                        id: snapshot.data[index].id,
                        title: snapshot.data[index].title,
                        cover: snapshot.data[index].cover,
                        url: snapshot.data[index].url,
                        synopsis: snapshot.data[index].synopsis == null
                            ? "No description"
                            : snapshot.data[index].synopsis,
                        type: snapshot.data[index].type,
                        year: snapshot.data[index].year == 'null'
                            ? 'Year unknown'
                            : snapshot.data[index].year,
                        status: snapshot.data[index].status,
                        tags: snapshot.data[index].tags,
                        author: snapshot.data[index].author,
                        source: 'MangaDex',
                        // scrapeDate: snapshot.data[index].scrapeDate,
                      );
                    }));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
