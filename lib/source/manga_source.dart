import 'package:first_app/source/model/chapter.dart';
import 'package:first_app/source/model/manga.dart';
import 'package:http/http.dart';

abstract class MangaSource {
  final String name = '';

  final String baseURL = '';

  final String sourceURL = '';

  Future<Response> updateLibraryRequest(String id);

  updateLibraryParse(Response response);

  Future<Response> popularMangaRequest(int offset);

  popularMangaParse(Response response);

  Future<Response> latestMangaRequest(int offset);

  latestMangaParse(Response response);

  Future<Response> searchMangaRequest(int offset, String query, String filter);

  searchMangaParse(Response response);

  Future<Response> mangaDetailsRequest(String id);

  mangaDetailsParse(Response response);

  Future<Response> chapterListRequest(String id);

  chapterListParse(Response response);

  Future<Response> pageListRequest(Chapter chapter);

  pageListParse(Response response);

  imageParse(Response response);

  getGenres(List<dynamic> genres);
}
