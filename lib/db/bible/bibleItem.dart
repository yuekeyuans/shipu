import 'bibleChapter.dart';
import 'bibleContentTable.dart';
import 'bibleOutlineTable.dart';

class BibleItem {
  // 0 => chapter
  // 1 => bible
  // 2 => outline
  int id;
  BibleChapter chapter;
  BibleContentTable bible;
  BibleOutlineTable outline;
  String content;

  BibleItem({this.id, this.chapter, this.bible, this.outline, this.content});
}
