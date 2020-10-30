import 'dart:convert';

import 'package:common_utils/common_utils.dart';
import 'package:sqflite/sqflite.dart';

import 'sqliteDb.dart';

class YnybJyTable {
  static const TABLENAME = "ynyb_jy";

  Map<String, String> comments = {};
  int days = -1;
  List<String> ids = [];
  bool isComplete = false;

  YnybJyTable({
    this.days,
    this.ids,
    this.isComplete,
    this.comments,
  });

  Map<String, dynamic> toMap() {
    return {'days': days, 'ids': ids, 'isComplete': isComplete, 'comments': comments.toString()};
  }

  factory YnybJyTable.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return YnybJyTable(days: map['days'] as int, ids: (map['ids'] as String).split(","), isComplete: map['isComplete'] == "yes", comments: {});
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'YnybJyTable(days: $days, ids: $ids, isComplete: $isComplete)';

  Future<YnybJyTable> queryByDate(DateTime date) async {
    var db = await MainDb().db;
    var result = await db.query(TABLENAME, where: "days = ?", whereArgs: [getDaysOfDate(date)]);
    var record = YnybJyTable();
    result.forEach((element) {
      record = YnybJyTable.fromMap(element);
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
