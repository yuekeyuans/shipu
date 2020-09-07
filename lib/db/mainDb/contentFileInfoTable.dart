import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/mainDb/sqliteDb.dart';

class ContentFileInfoTable {
  int id;
  String filepath;
  String filename;
  String inserttime;
  String lastopentime;

  static const String TABLENAME = "contentfileinfo";

  ContentFileInfoTable(
      {this.id,
      this.filepath,
      this.filename,
      this.inserttime,
      this.lastopentime});

  ContentFileInfoTable.fromPath(String path) {
    filepath = path;
    filename = path.split("/").last;
    inserttime = DateUtil.formatDateMs(DateUtil.getNowDateMs(),
        format: DateFormats.full);
    lastopentime = DateUtil.formatDateMs(DateUtil.getNowDateMs(),
        format: DateFormats.full);
  }

  ContentFileInfoTable.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    filepath = json['filepath'];
    filename = json['filename'];
    inserttime = json['inserttime'];
    lastopentime = json['lastopentime'];
  }

  ContentFileInfoTable.fromSql(Map<String, dynamic> json) {
    id = json['id'];
    filepath = json['filepath'];
    filename = json['filename'];
    inserttime = json['inserttime'];
    lastopentime = json['lastopentime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['filename'] = this.filename;
    data['filepath'] = this.filepath;
    data['inserttime'] = this.inserttime;
    data['lastopentime'] = this.lastopentime;
    return data;
  }

  Future<int> insert() async {
    var db = await MainDb().db;
    return await db.insert(TABLENAME, this.toJson());
  }

  Future<int> remove() async {
    var db = await MainDb().db;
    return await db
        .delete(TABLENAME, where: "filepath = ?", whereArgs: [filepath]);
  }

  Future<int> updateLastOpenTime() async {
    var db = await MainDb().db;
    this.lastopentime = DateUtil.formatDateMs(DateUtil.getNowDateMs(),
        format: DateFormats.full);
    return await db.update(TABLENAME, toJson(),
        where: "filepath = ?", whereArgs: [filepath]);
  }

  Future<ContentFileInfoTable> query() async {
    var db = await MainDb().db;
    var result =
        await db.query(TABLENAME, where: "filepath = ?", whereArgs: [filepath]);
    List<ContentFileInfoTable> contents = [];
    result.forEach((item) => contents.add(ContentFileInfoTable.fromSql(item)));
    if (contents.length > 0) {
      return contents.first;
    }
    return null;
  }

  Future<List<ContentFileInfoTable>> queryAll() async {
    var db = await MainDb().db;
    var result = await db.query(
      TABLENAME,
    );
    List<ContentFileInfoTable> contents = [];
    result.forEach((item) => contents.add(ContentFileInfoTable.fromSql(item)));
    return contents;
  }
}
