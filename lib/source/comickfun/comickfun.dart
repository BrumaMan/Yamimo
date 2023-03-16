import 'package:first_app/source/comickfun/format_chapter_name.dart';
import 'package:flutter/material.dart';
import 'package:first_app/source/comickfun/status_parser.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/model/manga.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ComickFun implements MangaSource {
  ComickFun({required this.lang});

  final String lang;
  @override
  String name = 'Comick';

  @override
  String baseURL = 'api.comick.fun';

  @override
  String sourceURL = 'https://comick.app';

  @override
  popularMangaRequest(int offset) async {
    Uri url = Uri.https(baseURL, "/search", {
      // 'includes[]': ['cover_art', 'author'],
      'sort': 'follow',
      // 'tachiyomi': 'true'
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  Future<List<Manga>> popularMangaParse(http.Response response) async {
    var responseData = convert.jsonDecode(response.body);
    late http.Response detailsResponse;

    List<Manga> comics = [];
    int index = 0;
    for (var singleComic in responseData) {
      if (singleComic['hid'] == null) {
        continue;
      }
      detailsResponse = await mangaDetailsRequest(singleComic['hid']);
      Manga comic = mangaDetailsParse(detailsResponse);
      // debugPrint('${comic.author}');
      //Adding user to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  Future<http.Response> latestMangaRequest(int offset) async {
    Uri url = Uri.https(baseURL, "/search", {
      // 'includes[]': ['cover_art', 'author'],
      'sort': 'uploaded',
      'tachiyomi': 'true',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  Future<List<Manga>> latestMangaParse(http.Response response) async {
    var responseData = convert.jsonDecode(response.body);
    late http.Response detailsResponse;

    List<Manga> comics = [];
    int index = 0;
    for (var singleComic in responseData) {
      if (singleComic['hid'] == null) {
        continue;
      }
      detailsResponse = await mangaDetailsRequest(singleComic['hid']);
      Manga comic = mangaDetailsParse(detailsResponse);
      // debugPrint('${comic.author}');
      //Adding user to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  Future<http.Response> searchMangaRequest(
      int offset, String query, String filter) async {
    Uri url = Uri.https(baseURL, "/search", {
      'q': query,
      // 'sort': 'follow',
      // 'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  searchMangaParse(http.Response response) async {
    var responseData = convert.jsonDecode(response.body);
    late http.Response detailsResponse;

    List<Manga> manga = [];
    int index = 0;
    for (var singleComic in responseData) {
      if (singleComic['hid'] == null) {
        continue;
      }
      detailsResponse = await mangaDetailsRequest(singleComic['hid']);

      Manga comic = mangaDetailsParse(detailsResponse);
      // debugPrint('${comic.author}');
      //Adding user to the list.
      manga.add(comic);
      index + 1;
    }
    return manga;
  }

  @override
  Future<http.Response> mangaDetailsRequest(String id) async {
    Uri url = Uri.https(baseURL, "/comic/$id");
    final response = await http.get(url);
    return response;
  }

  @override
  mangaDetailsParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body);
    Manga comic = Manga(
      id: responseData["comic"]['hid'],
      title: responseData["comic"]["title"] ?? responseData["comic"]["title"],
      altTitles: responseData["comic"]["md_titles"],
      cover:
          "https://meo.comick.pictures/${responseData["comic"]['md_covers'][0]['b2key']}",
      url: "$sourceURL/comic/${responseData["comic"]["hid"]}",
      synopsis: responseData["comic"]["desc"],
      type: responseData["comic"]['hid'],
      year: '${responseData["comic"]["year"]}',
      status: parseStatus(responseData["comic"]["status"]),
      tags: responseData["genres"],
      author: responseData['authors'].isNotEmpty
          ? responseData['authors'][0]['name']
          : 'Unknown author',
    );

    return comic;
  }

  @override
  Future<http.Response> chapterListRequest(String id) async {
    final response = await paginatedChapterListRequest(id, 1);
    return response;
  }

  Future<http.Response> paginatedChapterListRequest(String id, int page) async {
    Uri url = Uri.https(
        baseURL, "/comic/$id/chapters", {'lang': 'en', 'page': '$page'});
    final response = await http.get(url);
    return response;
  }

  @override
  Future<List<Chapter>> chapterListParse(http.Response response) async {
    var responseData = convert.jsonDecode(response.body);
    var chapterResponseData = responseData['chapters'];
    late var newResponse;
    late var newResponseData;

    List<String> requestURL = response.request!.url.toString().split('/');
    String mangaURL = '/comic/${requestURL[4]}';
    debugPrint("${responseData['total']}");

    num resultSize = chapterResponseData.length;
    int page = 2;

    while (responseData['total'] > resultSize) {
      newResponse = await paginatedChapterListRequest(requestURL[4], page);
      newResponseData = convert.jsonDecode(newResponse.body)['chapters'];

      chapterResponseData += newResponseData;

      resultSize += newResponseData.length;
      page++;
      debugPrint('$resultSize');
    }

    List<Chapter> chapters = [];
    int index = 0;
    for (var singleComic in chapterResponseData) {
      Chapter chapter = Chapter(
        id: singleComic["hid"],
        title: formatChapterName(
            singleComic['vol'], singleComic['chap'], singleComic["title"]),
        volume: singleComic["vol"],
        chapter: singleComic["chap"],
        pages: 0,
        url:
            "$sourceURL$mangaURL/${singleComic['hid']}-chapter-${singleComic['chap']}-en",
        publishAt: singleComic["created_at"],
        readableAt: singleComic["created_at"],
        scanGroup: singleComic['md_groups'].isEmpty
            ? 'Unknown'
            : singleComic['md_groups'][0]['title'] ?? 'Unknown',
        officialScan: false,
      );

      //Adding user to the list.
      chapters.add(chapter);
      index + 1;
    }
    return chapters;
  }

  @override
  Future<http.Response> pageListRequest(Chapter chapter) async {
    Uri url = Uri.https(baseURL, "/chapter/${chapter.id}");
    final response = await http.get(url);
    return response;
  }

  @override
  pageListParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)['chapter'];
    String? baseUrl = responseData["server"];
    String? hash = responseData["hash"];

    // print(responseData);

    //Creating a list to store input data;
    List<String> pages = [];
    List<Widget> tempPageViews = [];
    int index = 0;
    try {
      for (var page in responseData['md_images']) {
        //Adding user to the list.
        pages.add("https://meo3.comick.pictures/${page['b2key']}");
        tempPageViews.add(Image.network(
          "https://meo3.comick.pictures/${page['b2key']}",
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text("Can't load page"),
            );
          },
        ));
        // index + 1;
        // debugPrint("${page['b2key']}");
      }
    } catch (e) {
      pages.add('https://icons8.com/icon/21066/unavailable');
    }
    return pages;
  }

  @override
  imageParse(http.Response response) {
    // TODO: implement imageParse
    throw UnimplementedError();
  }

  @override
  getGenres(List genres) {
    List<Widget> tags = [];
    for (var tag in genres) {
      tags.add(Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.8)),
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(tag["name"],
            style: TextStyle(
              fontSize: 12,
            )),
      ));
    }
    return tags;
  }
}
