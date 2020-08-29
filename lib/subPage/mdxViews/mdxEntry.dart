import 'package:da_ka/subPage/mdxViews/mdxSqlite.dart';

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

  MdxEntry(
      {this.id,
      this.sortId,
      this.tagId,
      this.entry,
      this.text,
      this.mkdown,
      this.html,
      this.visiable,
      this.createdate,
      this.lastUpdateDate,
      this.lastViewDate});

  MdxEntry.fromJson(Map<String, dynamic> json) {
    this.id = json['id'];
    this.sortId = json["sortId"];
    this.tagId = json["tagId"];
    this.entry = json["entry"];
    this.text = json["text"];
    this.mkdown = json["mkdown"];
    this.html = json["html"];
    this.visiable = json['visiable'];
    this.createdate = json['createdate'];
    this.lastUpdateDate = json["lastUpdateDate"];
    this.lastViewDate = json["lastViewDate"];
  }

  MdxEntry.fromSql(Map<String, dynamic> json) {
    this.id = json['id'];
    this.sortId = json["sortId"];
    this.tagId = json["tagId"];
    this.entry = json["entry"];
    this.text = json["text"];
    this.mkdown = json["mkdown"];
    this.html = json["html"];
    this.visiable = json['visiable'];
    this.createdate = json['createdate'];
    this.lastUpdateDate = json["lastUpdateDate"];
    this.lastViewDate = json["lastViewDate"];
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
    if (result.length != 0) {
      var a = MdxEntry.fromSql(result.first);
      this.html = a.html == null ? "" : a.html;
      this.text = a.text == null ? "" : a.text;
      return this;
    }
    return null;
  }

  Future<List<MdxEntry>> queryIndexes() async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME,
        columns: ["id", "sortId", "tagId", "entry", "visiable"]);
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
    var result = await db.query(TABLENAME,
        columns: ["id", "sortId", "tagId", "entry", "visiable"],
        where: "entry like ?",
        whereArgs: ["%" + text + "%"]);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<MdxEntry> queryFromId(String id) async {
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, where: "id = ?", whereArgs: [id]);
    if (result.length != 0) {
      var a = MdxEntry.fromSql(result.first);
      return a;
    }
    return null;
  }
}
