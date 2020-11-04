import 'package:da_ka/db/bible/bibleDb.dart';
import 'package:da_ka/db/lifestudyDb/LifeStudyOutline.dart';
import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/db/mainDb/sqliteDb.dart';

class BibleOutlineTable {
  static const String TABLENAME = "outline";
  int id;
  int bookIndex;
  int chapter;
  int section;
  int flag;
  int level;
  String outline;

  BibleOutlineTable({this.id, this.bookIndex, this.chapter, this.section, this.flag, this.level, this.outline});

  BibleOutlineTable.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as int;
    bookIndex = json['book_index'] as int;
    chapter = json['chapter'] as int;
    section = json['section'] as int;
    flag = json['flag'] as int;
    level = json['level'] as int;
    outline = json["outline"] as String;
  }

  BibleOutlineTable.fromSql(Map<String, dynamic> json) {
    id = json['_id'] as int;
    bookIndex = json['book_index'] as int;
    chapter = json['chapter'] as int;
    section = json['section'] as int;
    flag = json['flag'] as int;
    level = json['level'] as int;
    outline = json["outline"] as String;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = id;
    data['book_index'] = bookIndex;
    data['chapter'] = chapter;
    data['section'] = section;
    data['flag'] = flag;
    data['level'] = level;
    data['outline'] = outline;
    return data;
  }

  Future<BibleOutlineTable> query() async {
    var db = await MainDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    List<BibleOutlineTable> outlines = [];
    result.forEach((item) => outlines.add(BibleOutlineTable.fromSql(item)));
    if (outlines.isNotEmpty) {
      return outlines.first;
    }
    return null;
  }

  List<BibleOutlineTable> queryByReciteBibleTableRecord(List<ReciteBibleTable> records) {
    var lst = <BibleOutlineTable>[];
    records.forEach((element) async {
      lst.addAll((await queryByIds(element.ids)));
    });
    return lst;
  }

  Future<BibleOutlineTable> queryById(int id) async {
    var lst = <BibleOutlineTable>[];
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    result.forEach((element) {
      lst.add(BibleOutlineTable.fromJson(element));
    });
    return lst.first;
  }

  Future<List<BibleOutlineTable>> queryByIds(List<String> ids) async {
    var lst = <BibleOutlineTable>[];
    var db = await BibleDb().db;

    var result = await db.query(TABLENAME, where: "_id in (${listToString(ids)})");
    result.forEach((element) {
      lst.add(BibleOutlineTable.fromJson(element));
    });
    return lst;
  }

  //查询书目中的最大值和最小值
  Future<List<int>> queryMinMaxId(int bookId) async {
    var db = await BibleDb().db;
    int min, max;
    var result = await db.query(TABLENAME, columns: ["min(_id), max(_id)"], where: "book_index = ?", whereArgs: [bookId]);

    result.forEach((element) {
      min = element.values.first as int;
      max = element.values.last as int;
    });
    return [min, max];
  }

  String listToString(List<String> strs) {
    if (strs == null) {
      return "";
    }
    return strs.join(",");
  }

  static Future<List<BibleOutlineTable>> queryByChaptersAndSections(int bookIndex, Map<int, List<int>> maps) async {
    assert(maps.isNotEmpty);
    //build sql
    var sql = "select * from ${LifeStudyOutline.TABLE_NAME} where book_index = $bookIndex and (";
    List<String> wheres = [];
    maps.forEach((key, value) {
      wheres.add("(chapter = $key and section in (${value.join(',')}))");
    });
    sql = sql + wheres.join(" or ") + ")";
    print(sql);
    var db = await BibleDb().db;
    var result = await db.rawQuery(sql);
    return result.map<BibleOutlineTable>((e) => BibleOutlineTable.fromJson(e)).toList();
  }
}
