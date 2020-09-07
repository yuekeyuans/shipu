import 'dart:convert';
import 'sqliteDb.dart';
import 'package:common_utils/common_utils.dart';

///旧约 一年一遍
class YnybJyTable {
  int days = -1;
  List<String> ids = [];
  bool isComplete = false;
  Map<String, String> comments = {};

  YnybJyTable();

  static const TABLENAME = "ynyb_xy";

  YnybJyTable.fromJson(Map<String, String> map) {
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

  Future<YnybJyTable> queryByDate(DateTime date) async {
    var db = await MainDb().db;
    var result = await db
        .query(TABLENAME, where: "days = ?", whereArgs: [getDaysOfDate(date)]);
    var record = YnybJyTable();
    result.forEach((element) {
      record = YnybJyTable.fromJson(element);
    });
    return record;
  }

  int getDaysOfDate(DateTime date) {
    var result = DateUtil.getDayOfYear(date);
    if (DateUtil.isLeapYear(date) && result > 59) {
      result -= 1;
    }
    return result;
  }
}
