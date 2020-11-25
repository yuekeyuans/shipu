import 'package:da_ka/db/lifestudyDb/LifeStudyDb.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';
import 'package:flustars/flustars.dart';

class LifeStudyTable {
  //数据
  static const Map<int, int> chapters = {
    1: 120,
    2: 185,
    3: 64,
    4: 53,
    5: 30,
    6: 15,
    7: 10,
    8: 8,
    9: 38,
    11: 23,
    13: 13,
    15: 5,
    16: 5,
    17: 3,
    18: 38,
    19: 45,
    20: 8,
    21: 2,
    22: 10,
    23: 54,
    24: 40,
    25: 4,
    26: 27,
    27: 17,
    28: 9,
    29: 7,
    30: 3,
    31: 1,
    32: 1,
    33: 4,
    34: 1,
    35: 3,
    36: 1,
    37: 1,
    38: 15,
    39: 4,
    40: 72,
    41: 70,
    42: 79,
    43: 51,
    44: 72,
    45: 69,
    46: 69,
    47: 59,
    48: 46,
    49: 97,
    50: 62,
    51: 65,
    52: 24,
    53: 7,
    54: 12,
    55: 8,
    56: 6,
    57: 2,
    58: 69,
    59: 14,
    60: 34,
    61: 13,
    62: 40,
    63: 2,
    64: 2,
    65: 5,
    66: 68,
  };

  //查找文章
  Future<List<LifeStudyRecord>> queryChapter({int bookIndex = 1, int chapter = 1}) async {
    String sql = """
      select * from outline where outline.book_index = ? and outline.chapter = ? union 
      select * from content where content.book_index = ? and content.chapter = ? order by section
    """;
    var db = await LifeStudyDb().db;
    var result = await db.rawQuery(sql, [bookIndex, chapter, bookIndex, chapter]);
    return result.map((e) => LifeStudyRecord.fromJson(e)).toList();
  }

  //根据时间查找文章
  Future<List<LifeStudyRecord>> queryArticleByDate(DateTime date) async {
    var index = queryIndexOfDay(curDate: date);
    var bookAndChapter = queryBookAndChapterByIndex(index);
    return await queryChapter(bookIndex: bookAndChapter.first, chapter: bookAndChapter.last);
  }

  // 使用某一天的日期推测其他的卷
  int queryIndexOfDay({DateTime curDate}) {
    DateTime reference = DateTime.parse("20200916");
    int page = 1195;
    curDate = curDate ?? DateTime.now();
    curDate = DateTime.parse(DateUtil.formatDate(curDate, format: DateFormats.y_mo_d));
    var inDays = curDate.difference(reference).inDays;
    return (page + inDays - 1) % 1984 + 1;
  }

  List<int> queryBookAndChapterByIndex(int index) {
    int count = 0;
    for (var key in chapters.keys) {
      if (index <= count + chapters[key]) {
        return [
          key,
          index - count,
        ];
      }
      count += chapters[key];
    }
    return [1, 1];
  }

  ///下一篇
  static List<int> queryNextPageByBookIndexAndChapter(int book, int chapter) {
    var max = chapters[book];
    if (chapter >= max) {
      if (book == 66) {
        return [-1, -1];
      }
      return [book + 1, 1];
    }
    return [book, chapter + 1];
  }

  /// 上一篇
  static List<int> queryPrevPageByBookIndexAndChapter(int book, int chapter) {
    if (chapter <= 1) {
      if (book == 1) {
        return [-1, -1];
      }
      var max = chapters[book - 1];
      return [book - 1, max];
    }
    return [book, chapter - 1];
  }
}
