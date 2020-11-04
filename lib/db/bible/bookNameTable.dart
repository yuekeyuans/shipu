import 'package:da_ka/db/bible/bibleDb.dart';

class BibleBookNameTable {
  static const TABLENAME = "book_name";
  int id;
  int bookIndex;
  String name;
  String acronymName;

  BibleBookNameTable();

  BibleBookNameTable.fromJson(Map<String, dynamic> json) {
    id = json["_id"] as int;
    bookIndex = json["book_index"] as int;
    name = json["name"] as String;
    acronymName = json["acronym_name"] as String;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    json['_id'] = id;
    json["name"] = name;
    json["book_index"] = bookIndex;
    json["acronym_name"] = acronymName;
    return json;
  }

  Future<int> queryBookId(String name) async {
    var id = -1;
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "name= ?", whereArgs: [name]);
    result.forEach((element) {
      id = BibleBookNameTable.fromJson(element).id;
    });
    return id;
  }

  static Future<String> queryBookName(int id) async {
    var name = "";
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "_id = ?", whereArgs: [id]);
    result.forEach((element) {
      name = BibleBookNameTable.fromJson(element).name;
    });
    return name;
  }

  Future<String> queryShortName(String fullName) async {
    var name = "";
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, where: "name = ?", whereArgs: [fullName]);
    result.forEach((element) {
      name = BibleBookNameTable.fromJson(element).acronymName;
    });
    return name;
  }

  //TODO:
  Map<String, String> queryMap() {
    return null;
  }

  Future<List<String>> queryBookNames() async {
    var list = <String>[];
    var db = await BibleDb().db;
    var result = await db.query(TABLENAME, columns: ["name"]);
    result.forEach((element) {
      var name = element.values.first;
      list.add(name as String);
    });
    return list;
  }
}
