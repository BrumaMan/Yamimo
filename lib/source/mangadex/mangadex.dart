import 'package:first_app/source/mangadex/format_chapter_name.dart';
import 'package:first_app/source/mangadex/status_parser.dart';
import 'package:first_app/source/model/manga_details.dart';
import 'package:flutter/material.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/model/manga.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class MangaDex implements MangaSource {
  MangaDex({required this.lang});

  final String lang;
  @override
  String name = 'MangaDex';

  @override
  String baseURL = 'api.mangadex.org';

  @override
  String sourceURL = 'https://mangadex.org';

  @override
  Future<http.Response> updateLibraryRequest(String id) async {
    Uri url = Uri.https("api.mangadex.org", "/manga/$id", {
      'includes[]': ['cover_art', 'author'],
      // 'includes[]': 'author',
    });
    final response = await http.get(url);
    return response;
  }

  @override
  updateLibraryParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)["data"];

    return {
      'id': responseData["id"],
      'title': responseData["attributes"]["title"]["en"] ??
          responseData["attributes"]["title"]["ja-ro"],
      'cover':
          'https://uploads.mangadex.org/covers/${responseData['id']}/${responseData["relationships"][responseData["relationships"].indexWhere((element) => element["type"] == "cover_art")]["attributes"]["fileName"]}.256.jpg',
      'url': responseData['attributes']['title']['en'] != null
          ? '$sourceURL/title/${responseData['id']}/${responseData['attributes']['title']['en'].toLowerCase()}'
          : '$sourceURL/title/${responseData['id']}/${responseData['attributes']['title']['ja-ro']}',
      'source': 'MangaDex',
    };
  }

  @override
  popularMangaRequest(int offset) async {
    Uri url = Uri.https("api.mangadex.org", "/manga", {
      'includes[]': ['cover_art', 'author'],
      'order[followedCount]': 'desc',
      'offset': offset == 0 ? '$offset' : '${offset * 100}',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  popularMangaParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)["data"];

    List<Manga> comics = [];
    int index = 0;
    for (var singleComic in responseData) {
      Manga comic = Manga(
        id: singleComic["id"],
        title: singleComic["attributes"]["title"]["en"] ??
            singleComic["attributes"]["title"]["ja-ro"],
        altTitles: singleComic["attributes"]["altTitles"],
        cover:
            'https://uploads.mangadex.org/covers/${singleComic['id']}/${singleComic["relationships"][singleComic["relationships"].indexWhere((element) => element["type"] == "cover_art")]["attributes"]["fileName"]}.256.jpg',
        url: singleComic['attributes']['title']['en'] != null
            ? '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['en'].toLowerCase()}'
            : '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['ja-ro']}',
        // ??
        //     '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['ja-ro'].toLowerCase()}',
      );
      // debugPrint('${comic.author}');
      //Adding user to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  latestMangaRequest(int offset) async {
    Uri url = Uri.https("api.mangadex.org", "/manga", {
      'includes[]': ['cover_art', 'author'],
      // 'order': { 'followedCount': 'desc'},
      'offset': offset == 0 ? '$offset' : '${offset * 100}',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  latestMangaParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)["data"];

    List<Manga> comics = [];
    int index = 0;
    for (var singleComic in responseData) {
      Manga comic = Manga(
        id: singleComic["id"],
        title: singleComic["attributes"]["title"]["en"] ??
            singleComic["attributes"]["title"]["ja-ro"],
        altTitles: singleComic["attributes"]["altTitles"],
        cover:
            'https://uploads.mangadex.org/covers/${singleComic['id']}/${singleComic["relationships"][singleComic["relationships"].indexWhere((element) => element["type"] == "cover_art")]["attributes"]["fileName"]}.256.jpg',
        url: singleComic['attributes']['title']['en'] != null
            ? '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['en'].toLowerCase()}'
            : '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['ja-ro']}',
      );
      // debugPrint('${comic.author}');
      //Adding user to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  searchMangaRequest(int offset, String query, String filter) async {
    Uri url = Uri.https("api.mangadex.org", "/manga", {
      'title': query,
      'includes[]': ['cover_art', 'author'],
      // 'includes[]': 'author',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  searchMangaParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)["data"];

    // print(responseData);

    //Creating a list to store input data;
    List<Manga> comics = [];
    int index = 0;
    for (var singleComic in responseData) {
      Manga comic = Manga(
        id: singleComic["id"],
        title: singleComic["attributes"]["title"]["en"] ??
            singleComic["attributes"]["title"]["ja-ro"],
        altTitles: singleComic["attributes"]["altTitles"],
        cover:
            'https://uploads.mangadex.org/covers/${singleComic['id']}/${singleComic["relationships"][singleComic["relationships"].indexWhere((element) => element["type"] == "cover_art")]["attributes"]["fileName"]}.256.jpg',
        url: singleComic['attributes']['title']['en'] != null
            ? '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['en'].toLowerCase()}'
            : '$sourceURL/title/${singleComic['id']}/${singleComic['attributes']['title']['ja-ro']}',
      );
      // debugPrint('${comic.id}');
      //Adding comic to the list.
      comics.add(comic);
      index + 1;
    }
    return comics;
  }

  @override
  Future<http.Response> mangaDetailsRequest(String id) async {
    Uri url = Uri.https("api.mangadex.org", "/manga/$id", {
      'includes[]': ['cover_art', 'author'],
      // 'includes[]': 'author',
    });
    final response = await http.get(url);
    return response;
  }

  @override
  MangaDetails mangaDetailsParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body)["data"];

    MangaDetails manga = MangaDetails(
      synopsis: responseData["attributes"]["description"]["en"] == null
          ? 'No description'
          : responseData["attributes"]["description"]["en"],
      type: responseData["type"],
      year: responseData["attributes"]["year"] == null
          ? 'Year unknown'
          : '${responseData["attributes"]["year"]}',
      status: parseStatus(responseData["attributes"]["status"]),
      tags: responseData["attributes"]["tags"],
      author: responseData["relationships"][responseData["relationships"]
                      .indexWhere((element) => element["type"] == "author") ==
                  -1
              ? 0
              : responseData["relationships"].indexWhere((element) =>
                  element["type"] == "author")]["attributes"]["name"] ??
          'Unknown author',
    );

    return manga;
  }

  @override
  Future<http.Response> chapterListRequest(String id) async {
    final response = await paginatedChapterListRequest(id, 0);
    return response;
  }

  Future<http.Response> paginatedChapterListRequest(
      String id, num offset) async {
    Uri url = Uri.https("api.mangadex.org", "/manga/$id/feed", {
      'translatedLanguage[]': "en",
      'includes[]': 'scanlation_group',
      'offset': '$offset',
      'limit': '100'
    });
    final response = await http.get(url);
    return response;
  }

  @override
  chapterListParse(http.Response response) async {
    var responseData = convert.jsonDecode(response.body);
    var chapterResponseData = responseData['data'];
    late var newResponse;
    late var newResponseData;

    // print(responseData);
    List<String> requestURL = response.request!.url.toString().split('/');
    // String mangaURL = '/comic/${requestURL[4]}';

    num resultSize = chapterResponseData.length;
    num offset = 100;
    num prevOffset = offset;

    while (responseData['total'] > resultSize) {
      newResponse = await paginatedChapterListRequest(requestURL[4], offset);
      newResponseData = convert.jsonDecode(newResponse.body)['data'];

      chapterResponseData += newResponseData;

      resultSize += newResponseData.length;
      prevOffset = offset;
      offset += 100;
      if (offset >= responseData['total']) {
        num diff = offset - responseData['total'];
        num newOffset = 100 - diff;
        offset = prevOffset + newOffset;
      }
    }

    //Creating a list to store input data;
    List<Chapter> chapters = [];
    int index = 0;
    for (var singleComic in chapterResponseData) {
      Chapter chapter = Chapter(
        id: singleComic["id"],
        title: formatChapterName(
            singleComic["attributes"]["volume"],
            singleComic["attributes"]["chapter"],
            singleComic["attributes"]["title"]),
        volume: singleComic["attributes"]["volume"],
        chapter: singleComic["attributes"]["chapter"],
        pages: singleComic["attributes"]["pages"],
        url: "https://mangadex.org/chapter/${singleComic['id']}/1",
        publishAt: singleComic["attributes"]["publishAt"],
        readableAt: singleComic["attributes"]["readableAt"],
        scanGroup: singleComic["relationships"]?[0]?["attributes"]?["name"],
        officialScan: singleComic["relationships"]?[0]?["attributes"]
            ?["official"],
        downloaded: false,
      );

      //Adding user to the list.
      chapters.add(chapter);
      index + 1;
    }
    chapters.sort((a, b) {
      if (b.chapter is int || a.chapter is int) {
        return int.parse(b.chapter!).compareTo(int.parse(a.chapter!));
      } else {
        return double.parse(b.chapter!).compareTo(double.parse(a.chapter!));
      }
    });
    return chapters;
  }

  @override
  Future<http.Response> pageListRequest(Chapter chapter) async {
    Uri url = Uri.https("api.mangadex.org", "/at-home/server/${chapter.id}");
    final response = await http.get(url);
    return response;
  }

  @override
  pageListParse(http.Response response) {
    var responseData = convert.jsonDecode(response.body);
    String? baseUrl = responseData["baseUrl"];
    String? hash = responseData["chapter"]?["hash"];

    // print(responseData);

    //Creating a list to store input data;
    List<String> pages = [];
    List<Widget> tempPageViews = [];
    int index = 0;
    try {
      for (var page in responseData["chapter"]["data"]) {
        //Adding user to the list.
        pages.add('$baseUrl/data/$hash/$page');
        tempPageViews.add(Image.network(
          '$baseUrl/data/$hash/$page',
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text("Can't load page"),
            );
          },
        ));
        // index + 1;
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
        margin: EdgeInsets.only(right: 4.0),
        child: Text(tag["attributes"]["name"]["en"],
            style: TextStyle(
              fontSize: 12,
            )),
      ));
    }
    return tags;
  }

  @override
  isWebtoon(List tags) {
    return tags.indexWhere(
        (element) => element["attributes"]["name"]["en"] == 'Long Strip');
  }
}
