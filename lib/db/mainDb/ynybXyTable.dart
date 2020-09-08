import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'sqliteDb.dart';
import 'package:common_utils/common_utils.dart';

///新约 一年一遍
class YnybXyTable {
  int days = -1;
  List<String> ids = [];
  bool isComplete = false;
  Map<String, String> comments = {};

  YnybXyTable();

  static const TABLENAME = "ynyb_xy";

  YnybXyTable.fromJson(Map<String, String> map) {
    ids = map["ids"].split(",");
    days = int.parse(map["days"]);
    isComplete = (map["isComplete"].toString() == true.toString());
    comments = json.decode(map["comments"]);
  }

  toJson() {
    Map<String, String> map = {};
    map["ids"] = ids.join(",");
    map["days"] = days.toString();
    map["isComplete"] = isComplete.toString();
    map["comments"] = json.encode(comments);
    return json;
  }

  Future<YnybXyTable> queryByDate(DateTime date) async {
    var db = await MainDb().db;
    var result = await db
        .query(TABLENAME, where: "days = ?", whereArgs: [getDaysOfDate(date)]);
    var record = YnybXyTable();
    result.forEach((element) {
      record = YnybXyTable.fromJson(element);
    });
    return record;
  }

  Future<bool> queryIsComplete(DateTime date) async {
    var db = await MainDb().db;
    var count = Sqflite.firstIntValue(await db.query(TABLENAME,
        columns: ["count(1)"],
        where: "days = ? and isComplete = ?",
        whereArgs: [getDaysOfDate(date), true.toString()]));
    return count != 0;
  }

  Future<void> toggleIsComplete(DateTime date, bool orignalValue) async {
    var db = await MainDb().db;
    await db.update(
      TABLENAME,
      {"isComplete": (!orignalValue).toString()},
      where: "days = ?",
      whereArgs: [getDaysOfDate(date)],
    );
  }

  int getDaysOfDate(DateTime date) {
    var result = DateUtil.getDayOfYear(date);
    if (DateUtil.isLeapYear(date) && result > 59) {
      result -= 1;
    }
    return result;
  }
}
