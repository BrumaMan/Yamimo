import 'package:first_app/source/comickfun/format_chapter_name.dart';
import 'package:first_app/source/model/manga_details.dart';
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
  Future<http.Response> updateLibraryRequest(String id) async {
    Uri url = Uri.https(baseURL, "/comic/$id");
    final response = await http.get(url);
    return response;
  }

  @override
  updateLibraryParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)["comic"];

    return {
      'id': responseData["hid"],
      'title': responseData["title"],
      'cover':
          "https://meo.comick.pictures/${responseData['md_covers'][0]['b2key']}",
      'url': "$sourceURL/comic/${responseData["hid"]}",
      'source': 'Comick',
    };
  }

  @override
  popularMangaRequest(int offset) async {
    Uri url = Uri.https(baseURL, "/v1.0/search", {
      // 'includes[]': ['cover_art', 'author'],
      'sort': 'follow',
      // 'tachiyomi': 'true'
      'page': '${offset + 1}',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  popularMangaParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body);

    List<Manga> comics = [];
    if (response.statusCode != 200) {
      return comics;
    }
    int index = 0;
    for (var singleComic in responseData) {
      if (singleComic['hid'] == null) {
        continue;
      }
      Manga comic = Manga(
        id: singleComic['hid'],
        title: singleComic["title"] ?? singleComic["title"],
        altTitles: singleComic["genres"],
        cover:
            "https://meo.comick.pictures/${singleComic['md_covers'][0]['b2key']}",
        url: "$sourceURL/comic/${singleComic["hid"]}",
      );
      // debugPrint('${comic.author}');
      //Adding user to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  Future<http.Response> latestMangaRequest(int offset) async {
    Uri url = Uri.https(baseURL, "/v1.0/search", {
      // 'includes[]': ['cover_art', 'author'],
      'sort': 'uploaded',
      'tachiyomi': 'true',
      'page': '${offset + 1}',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  latestMangaParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body);

    List<Manga> comics = [];
    if (response.statusCode != 200) {
      return comics;
    }
    int index = 0;
    for (var singleComic in responseData) {
      if (singleComic['hid'] == null) {
        continue;
      }
      Manga comic = Manga(
        id: singleComic['hid'],
        title: singleComic["title"] ?? singleComic["title"],
        altTitles: singleComic["genres"],
        cover:
            "https://meo.comick.pictures/${singleComic['md_covers'][0]['b2key']}",
        url: "$sourceURL/comic/${singleComic["hid"]}",
      );
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
    Uri url = Uri.https(baseURL, "/v1.0/search", {
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

    List<Manga> manga = [];
    if (response.statusCode != 200) {
      return manga;
    }
    int index = 0;
    for (var singleComic in responseData) {
      if (singleComic['hid'] == null) {
        continue;
      }
      Manga comic = Manga(
        id: singleComic['hid'],
        title: singleComic["title"] ?? singleComic["title"],
        altTitles: singleComic["genres"],
        cover:
            "https://meo.comick.pictures/${singleComic['md_covers'][0]['b2key']}",
        url: "$sourceURL/comic/${singleComic["hid"]}",
      );
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
  MangaDetails mangaDetailsParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body);
    MangaDetails comic = MangaDetails(
      synopsis: responseData["comic"]["desc"] == null
          ? 'No description'
          : responseData["comic"]["desc"],
      type: responseData["comic"]['hid'],
      year: responseData["comic"]["year"] == null
          ? 'Year unknown'
          : '${responseData["comic"]["year"]}',
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
        scanGroup: singleComic['group_name'] == null
            // singleComic['md_chapters_groups'].isEmpty
            ? 'Unknown'
            : singleComic['group_name'].isEmpty
                ? 'Unknown'
                : singleComic['group_name'][0],
        officialScan: singleComic['group_name'] == null
            ? false
            : singleComic['group_name'].isEmpty
                ? false
                : singleComic['group_name'][0] == "Official"
                    ? true
                    : false,
        downloaded: false,
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

    // print(responseData);

    //Creating a list to store input data;
    List<String> pages = [];
    List<Widget> tempPageViews = [];
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
      tags.add(Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: ActionChip(
          label: Text(tag["name"],
              style: TextStyle(
                fontSize: 12,
              )),
          onPressed: () {},
        ),
      ));
    }
    return tags;
  }

  @override
  isWebtoon(List tags) {
    return tags.indexWhere((element) => element["name"] == 'Long Strip');
  }
}
