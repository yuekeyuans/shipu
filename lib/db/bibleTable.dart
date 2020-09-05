import 'package:da_ka/db/bibleDb.dart';
import 'package:da_ka/db/recitebibleTable.dart';
import 'package:da_ka/db/sqliteDb.dart';
import 'package:sqflite/sqflite.dart';

/// 文件当中目前有两张表，现在仅提供一张表，另外一张暂时不提供
class BibleTable {
  static const String TABLENAME = "content";
  int id;
  int bookIndex;
  int chapter;
  int section;
  int flag;
  String content;

  BibleTable(
      {this.id,
      this.bookIndex,
      this.chapter,
      this.section,
      this.flag,
      this.content});

  BibleTable.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    bookIndex = json['book_index'];
    chapter = json['chapter'];
    section = json['section'];
    flag = json['flag'];
    content = json["content"];
  }

  BibleTable.fromSql(Map<String, dynamic> json) {
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

  Future<BibleTable> query() async {
    var db = await DatabaseHelper().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    List<BibleTable> contents = [];
    result.forEach((item) => contents.add(BibleTable.fromSql(item)));
    if (contents.length > 0) {
      return contents.first;
    }
    return null;
  }

  List<BibleTable> queryByReciteBibleTableRecord(
      List<ReciteBibleTable> records) {
    var lst = <BibleTable>[];
    records.forEach((element) async {
      lst.addAll((await queryByIds(element)));
    });
    return lst;
  }

  Future<BibleTable> queryById(int id) async {
    var lst = [];
    var db = await BibleDatabaseHelper().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    result.forEach((element) {
      lst.add(BibleTable.fromJson(element));
    });
    return lst.first;
  }

  Future<List<BibleTable>> queryByIds(ReciteBibleTable record) async {
    var lst = <BibleTable>[];
    var db = await BibleDatabaseHelper().db;
    var ids = record.ids;
    ids.add("-1");
    var result = await db.query(TABLENAME,
        where: "_id in (${record.listToString(ids)})");
    result.forEach((element) {
      lst.add(BibleTable.fromJson(element));
    });
    return lst;
  }

  //查询书目中的最大值和最小值
  Future<List<int>> queryMinMaxId(int bookId) async {
    var db = await BibleDatabaseHelper().db;
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
}

class BookName {
  static const TABLENAME = "book_name";
  int id;
  int bookIndex;
  String name;
  String acronymName;

  BookName();

  BookName.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    bookIndex = json["book_index"];
    name = json["name"];
    acronymName = json["acronym_name"];
  }

  toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json['_id'] = id;
    json["name"] = name;
    json["book_index"] = bookIndex;
    json["acronym_name"] = acronymName;
    return json;
  }

  Future<int> queryBookId(String name) async {
    var id = -1;
    var db = await BibleDatabaseHelper().db;
    var result = await db.query(TABLENAME, where: "name= ?", whereArgs: [name]);
    result.forEach((element) {
      id = BookName.fromJson(element).id;
    });
    return id;
  }

  static Future<String> queryBookName(int id) async {
    var name = "";
    var db = await BibleDatabaseHelper().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    result.forEach((element) {
      name = BookName.fromJson(element).name;
    });
    return name;
  }

  Future<String> queryShortName(String fullName) async {
    var name = "";
    var db = await BibleDatabaseHelper().db;
    var result =
        await db.query(TABLENAME, where: "name = ?", whereArgs: [fullName]);
    result.forEach((element) {
      name = BookName.fromJson(element).acronymName;
    });
    return name;
  }

  Future<List<String>> queryBookNames() async {
    var list = <String>[];
    var db = await BibleDatabaseHelper().db;
    var result = await db.query(TABLENAME, columns: ["name"]);
    result.forEach((element) {
      var name = element.values.first;
      list.add(name);
    });
    return list;
  }
}
