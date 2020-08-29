import 'package:da_ka/subPage/mdxViews/mdxSqlite.dart';

class MdxDict {
  int id;
  String title;
  String description;
  String image;
  String html;

  static const TABLENAME = "dict";

  MdxDict({this.id, this.title, this.description, this.image, this.html});

  MdxDict.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    description = json["description"];
    image = json["image"];
    html = json["html"];
  }

  MdxDict.fromSql(Map<String, dynamic> json) {
    print(json);
    id = json["id"];
    title = json["title"];
    description = json["description"];
    image = json["image"];
    html = json["html"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = new Map<String, dynamic>();
    json["id"] = id;
    json["title"] = title;
    json["description"] = description;
    json["image"] = image;
    json["html"] = html;
    return json;
  }

  Future<List<MdxDict>> queryAll() async {
    final List<MdxDict> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME);
    result.forEach((item) {
      print(item);
      list.add(MdxDict.fromSql(item));
    });
    print(list);
    return list;
  }

  Future<String> queryHtml() async {
    String html;
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, columns: ["html"]);
    result.forEach((item) {
      print(item);
      html = MdxDict.fromSql(item).html;
    });
    return html == null ? "" : html;
  }
}
