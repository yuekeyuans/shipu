import 'package:da_ka/db/bible/bibleDb.dart';
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

  BibleOutlineTable(
      {this.id,
      this.bookIndex,
      this.chapter,
      this.section,
      this.flag,
      this.level,
      this.outline});

  BibleOutlineTable.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    bookIndex = json['book_index'];
    chapter = json['chapter'];
    section = json['section'];
    flag = json['flag'];
    level = json['level'];
    outline = json["outline"];
  }

  BibleOutlineTable.fromSql(Map<String, dynamic> json) {
    id = json['_id'];
    bookIndex = json['book_index'];
    chapter = json['chapter'];
    section = json['section'];
    flag = json['flag'];
    level = json['level'];
    outline = json["outline"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['book_index'] = this.bookIndex;
    data['chapter'] = this.chapter;
    data['section'] = this.section;
    data['flag'] = this.flag;
    data['level'] = this.level;
    data['outline'] = this.outline;
    return data;
  }

  Future<BibleOutlineTable> query() async {
    var db = await MainDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    List<BibleOutlineTable> outlines = [];
    result.forEach((item) => outlines.add(BibleOutlineTable.fromSql(item)));
    if (outlines.length > 0) {
      return outlines.first;
    }
    return null;
  }

  List<BibleOutlineTable> queryByReciteBibleTableRecord(
      List<ReciteBibleTable> records) {
    var lst = <BibleOutlineTable>[];
    records.forEach((element) async {
      lst.addAll((await queryByIds(element.ids)));
    });
    return lst;
  }

  Future<BibleOutlineTable> queryById(int id) async {
    var lst = [];
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

    var result =
        await db.query(TABLENAME, where: "_id in (${listToString(ids)})");
    result.forEach((element) {
      lst.add(BibleOutlineTable.fromJson(element));
    });
    return lst;
  }

  //查询书目中的最大值和最小值
  Future<List<int>> queryMinMaxId(int bookId) async {
    var db = await BibleDb().db;
    int min, max;
    var result = await db.query(TABLENAME,
        columns: ["min(_id), max(_id)"],
        where: "book_index = ?",
        whereArgs: [bookId]);

    result.forEach((element) {
      min = element.values.first;
      max = element.values.last;
    });
    return [min, max];
  }

  String listToString(List<String> strs) {
    if (strs == null) {
      return "";
    }
    return strs.join(",");
  }
}
