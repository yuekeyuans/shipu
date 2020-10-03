import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import 'sqliteDb.dart';
import 'package:common_utils/common_utils.dart';

///旧约 一年一遍
class YnybJyTable {
  YnybJyTable();

  YnybJyTable.fromJson(Map<String, dynamic> map) {
    ids = map["ids"].split(",") as List<String>;
    days = int.parse(map["days"] as String);
    isComplete = (map["isComplete"].toString() == true.toString());
    comments = json.decode(map["comments"] as String) as Map<String, String>;
  }

  static const TABLENAME = "ynyb_jy";

  Map<String, String> comments = {};
  int days = -1;
  List<String> ids = [];
  bool isComplete = false;

  Map<String, String> toJson() {
    var map = <String, String>{};
    map["ids"] = ids.join(",");
    map["days"] = days.toString();
    map["isComplete"] = isComplete.toString();
    map["comments"] = json.encode(comments).toString();
    return map;
  }

  Future<YnybJyTable> queryByDate(DateTime date) async {
    var db = await MainDb().db;
    var result = await db.query(TABLENAME, where: "days = ?", whereArgs: [getDaysOfDate(date)]);
    var record = YnybJyTable();
    result.forEach((element) {
      record = YnybJyTable.fromJson(element);
    });
    return record;
  }

  Future<bool> queryIsComplete(DateTime date) async {
    var db = await MainDb().db;
    var count = Sqflite.firstIntValue(await db.query(TABLENAME, columns: ["count(1)"], where: "days = ? and isComplete = ?", whereArgs: [getDaysOfDate(date), true.toString()]));
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
