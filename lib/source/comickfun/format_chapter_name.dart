String formatChapterName(String? vol, String? chap, String? title) {
  String chapterName = '';
  if (vol != null) {
    if (chap == null) {
      chapterName += 'Volume $vol';
    } else {
      chapterName += 'Vol. $vol';
    }
  }

  if (chap != null) {
    if (vol == null) {
      chapterName += 'chapter $chap';
    } else {
      chapterName += ', ch. $chap';
    }
  }

  if (title != null) {
    if (chap == null) {
      chapterName += title;
    } else {
      chapterName += ': $title';
    }
  }

  return chapterName;
}
