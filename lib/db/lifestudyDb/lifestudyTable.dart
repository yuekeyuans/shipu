import 'package:da_ka/db/lifestudyDb/LifeStudyDb.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';

class LifeStudyTable {
  Future<List<LifeStudyRecord>> queryChapter() async {
    String sql = """
      select * from outline where outline.book_index = 1 and outline.chapter = 1 union 
      select * from content where content.book_index = 1 and content.chapter = 1 order by section
    """;
    var db = await LifeStudyDb().db;
    var result = await db.rawQuery(sql);
    return result.map((e) => LifeStudyRecord.fromJson(e)).toList();
  }
}
