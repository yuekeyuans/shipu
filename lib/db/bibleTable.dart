import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bibleDb.dart';
import 'package:da_ka/db/sqliteDb.dart';

/// 文件当中目前有两张表，现在仅提供一张表，另外一张暂时不提供
class BibleTable {
  int id;
  int bookIndex;
  int chapter;
  int section;
  int flag;
  String content;

  static const String TABLENAME = "content";

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

  Future<List<BibleTable>> queryByDay(DateTime date) async {
    var list = <BibleTable>[];
    var db = await BibleDatabaseHelper().db;
    var result = await db.query(
      TABLENAME,
    );
    return list;
  }
}

class BookName {
  int id;
  int bookIndex;
  String name;
  String acronymName;

  String TABLENAME = "book_name";

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
      var a = BookName.fromJson(element);
      id = a.id;
    });
    return id;
  }

  Future<List<BookName>> queryBookNames() async {
    var list = <BookName>[];
    var db = await BibleDatabaseHelper().db;
    var result = await db.query(TABLENAME);
    result.forEach((element) {
      var book = BookName.fromJson(element);
      list.add(book);
    });
    return list;
  }
}
