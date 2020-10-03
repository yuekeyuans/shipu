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
      {id,
      filepath,
      filename,
      inserttime,
      lastopentime});

  ContentFileInfoTable.fromPath(String path) {
    filepath = path;
    filename = path.split("/").last;
    inserttime = DateUtil.formatDateMs(DateUtil.getNowDateMs(),
        format: DateFormats.full);
    lastopentime = DateUtil.formatDateMs(DateUtil.getNowDateMs(),
        format: DateFormats.full);
  }

  ContentFileInfoTable.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    filepath = json['filepath'] as String;
    filename = json['filename'] as String;
    inserttime = json['inserttime'] as String;
    lastopentime = json['lastopentime'] as String;
  }

  ContentFileInfoTable.fromSql(Map<String, dynamic> json) {
    id = json['id'] as int;
    filepath = json['filepath'] as String;
    filename = json['filename'] as String;
    inserttime = json['inserttime'] as String;
    lastopentime = json['lastopentime'] as String;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['filename'] = filename;
    data['filepath'] = filepath;
    data['inserttime'] = inserttime;
    data['lastopentime'] = lastopentime;
    return data;
  }

  Future<int> insert() async {
    var db = await MainDb().db;
    return await db.insert(TABLENAME, toJson());
  }

  Future<int> remove() async {
    var db = await MainDb().db;
    return await db
        .delete(TABLENAME, where: "filepath = ?", whereArgs: [filepath]);
  }

  Future<int> updateLastOpenTime() async {
    var db = await MainDb().db;
    lastopentime = DateUtil.formatDateMs(DateUtil.getNowDateMs(),
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
    if (contents.isNotEmpty) {
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
