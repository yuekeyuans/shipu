import 'package:da_ka/db/bible/bibleDb.dart';
import 'package:da_ka/db/bible/bibleFootnoteTable.dart';
import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/db/mainDb/sqliteDb.dart';

class BibleContentTable {
  static const String TABLENAME = "content";
  List<BibleFotnoteTable> footNotes = [];

  int id;
  int bookIndex;
  int chapter;
  int section;
  int flag;
  String content;
  String mark;

  BibleContentTable({this.id, this.bookIndex, this.chapter, this.section, this.flag, this.content, this.mark});

  BibleContentTable.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as int;
    bookIndex = json['book_index'] as int;
    chapter = json['chapter'] as int;
    section = json['section'] as int;
    flag = json['flag'] as int;
    content = json["content"] as String;
    mark = json['mark'] as String;
  }

  BibleContentTable.fromSql(Map<String, dynamic> json) {
    id = json['_id'] as int;
    bookIndex = json['book_index'] as int;
    chapter = json['chapter'] as int;
    section = json['section'] as int;
    flag = json['flag'] as int;
    content = json["content"] as String;
    mark = json["mark"] as String;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['book_index'] = bookIndex;
    data['chapter'] = chapter;
    data['section'] = section;
    data['flag'] = flag;
    data['content'] = content;
    data['mark'] = mark;
    return data;
  }

  Future<BibleContentTable> query() async {
    var db = await MainDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    List<BibleContentTable> contents = [];
    result.forEach((item) => contents.add(BibleContentTable.fromSql(item)));
    if (contents.isNotEmpty) {
      return contents.first;
    }
    return null;
  }

  List<BibleContentTable> queryByReciteBibleTableRecord(List<ReciteBibleTable> records) {
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
    return lst.first as BibleContentTable;
  }

  Future<List<BibleContentTable>> queryByIds(List<String> ids) async {
    var lst = <BibleContentTable>[];
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "_id in (${listToString(ids)})");
    result.forEach((element) {
      lst.add(BibleContentTable.fromJson(element));
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

  Future<void> setMarked(String info) async {
    mark = info;
    var db = await BibleDb().db;
    await db.update(TABLENAME, toJson(), where: "_id = ?", whereArgs: [id]);
  }

  Future<List<BibleContentTable>> queryByBookAndChapter(int bookId, int chapter) async {
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "book_index = ? and chapter = ?", whereArgs: [bookIndex, chapter]);
    return result.map<BibleContentTable>((e) => BibleContentTable.fromJson(e)).toList();
  }
}
