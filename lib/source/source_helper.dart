import 'package:first_app/source/comickfun/comickfun.dart';
import 'package:first_app/source/manga_source.dart';
import 'package:first_app/source/mangadex/mangadex.dart';
import 'package:first_app/source/mangaplus/mangaplus.dart';

class SourceHelper {
  final String MANGADEX = 'MangaDex';
  final String COMICK = 'Comick';
  final String MANGAPLUS = 'MangaPlus';

  getSource(String name) {
    late MangaSource source;
    if (name == MANGADEX) {
      source = MangaDex(lang: 'en');
    } else if (name == COMICK) {
      source = ComickFun(lang: 'en');
    } else if (name == MANGAPLUS) {
      source = MangaPlus(lang: 'en');
    }
    return source;
  }
}
