import 'package:da_ka/db/bible/bibleDb.dart';
import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/db/mainDb/sqliteDb.dart';

class BibleContentTable {
  static const String TABLENAME = "content";
  int id;
  int bookIndex;
  int chapter;
  int section;
  int flag;
  String content;

  BibleContentTable(
      {this.id,
      this.bookIndex,
      this.chapter,
      this.section,
      this.flag,
      this.content});

  BibleContentTable.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    bookIndex = json['book_index'];
    chapter = json['chapter'];
    section = json['section'];
    flag = json['flag'];
    content = json["content"];
  }

  BibleContentTable.fromSql(Map<String, dynamic> json) {
    id = json['_id'];
    bookIndex = json['book_index'];
    chapter = json['chapter'];
    section = json['section'];
    flag = json['flag'];
    content = json["content"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['book_index'] = this.bookIndex;
    data['chapter'] = this.chapter;
    data['section'] = this.section;
    data['flag'] = this.flag;
    data['content'] = this.content;
    return data;
  }

  Future<BibleContentTable> query() async {
    var db = await MainDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    List<BibleContentTable> contents = [];
    result.forEach((item) => contents.add(BibleContentTable.fromSql(item)));
    if (contents.length > 0) {
      return contents.first;
    }
    return null;
  }

  List<BibleContentTable> queryByReciteBibleTableRecord(
      List<ReciteBibleTable> records) {
    var lst = <BibleContentTable>[];
    records.forEach((element) async {
      lst.addAll((await queryByIds(element.ids)));
    });
    return lst;
  }

  Future<BibleContentTable> queryById(int id) async {
    var lst = [];
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    result.forEach((element) {
      lst.add(BibleContentTable.fromJson(element));
    });
    return lst.first;
  }

  Future<List<BibleContentTable>> queryByIds(List<String> ids) async {
    var lst = <BibleContentTable>[];
    var db = await BibleDb().db;

    var result =
        await db.query(TABLENAME, where: "_id in (${listToString(ids)})");
    result.forEach((element) {
      lst.add(BibleContentTable.fromJson(element));
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
