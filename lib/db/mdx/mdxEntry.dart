import 'mdxSqlite.dart';

class MdxEntry {
  String id;
  int sortId;
  String tagId;
  String entry;
  String text;
  String mkdown;
  String html;
  String visiable;
  String createdate;
  String lastUpdateDate;
  String lastViewDate;

  static const TABLENAME = "entry";

  MdxEntry({id, sortId, tagId, entry, text, mkdown, html, visiable, createdate, lastUpdateDate, lastViewDate});

  MdxEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    sortId = json["sortId"] as int;
    tagId = json["tagId"] as String;
    entry = json["entry"] as String;
    text = json["text"] as String;
    mkdown = json["mkdown"] as String;
    html = json["html"] as String;
    visiable = json['visiable'] as String;
    createdate = json['createdate'] as String;
    lastUpdateDate = json["lastUpdateDate"] as String;
    lastViewDate = json["lastViewDate"] as String;
  }

  MdxEntry.fromSql(Map<String, dynamic> json) {
    id = json['id'] as String;
    sortId = json["sortId"] as int;
    tagId = json["tagId"] as String;
    entry = json["entry"] as String;
    text = json["text"] as String;
    mkdown = json["mkdown"] as String;
    html = json["html"] as String;
    visiable = json['visiable'] as String;
    createdate = json['createdate'] as String;
    lastUpdateDate = json["lastUpdateDate"] as String;
    lastViewDate = json["lastViewDate"] as String;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map["id"] = id;
    map["sortId"] = sortId;
    map["tagId"] = tagId;
    map["entry"] = entry;
    map["text"] = text;
    map["mkdown"] = mkdown;
    map["html"] = html;
    map["visiable"] = visiable;
    map["createdate"] = createdate;
    map["lastUpdateDate"] = lastUpdateDate;
    map["lastViewDate"] = lastViewDate;
    return map;
  }

  Future<List<MdxEntry>> queryAll() async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<MdxEntry> load() async {
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, where: "id = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      var a = MdxEntry.fromSql(result.first);
      html = a.html ?? "";
      text = a.text ?? "";
      return this;
    }
    return null;
  }

  Future<List<MdxEntry>> queryIndexes() async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, columns: ["id", "sortId", "tagId", "entry", "visiable"]);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<List<MdxEntry>> queryIndexesBySearch(String text) async {
    if (text == "" || text == null) {
      return queryIndexes();
    }

    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, columns: ["id", "sortId", "tagId", "entry", "visiable"], where: "entry like ?", whereArgs: ["%" + text + "%"]);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<MdxEntry> queryFromId(String id) async {
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, where: "id = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      var a = MdxEntry.fromSql(result.first);
      return a;
    }
    return null;
  }

  Future<List<MdxEntry>> queryIndexesByTag(String tag) async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(
      TABLENAME,
      columns: ["id", "sortId", "tagId", "entry", "visiable"],
      where: "tagId = ?", 
      whereArgs: [tag],
    );
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }
}
