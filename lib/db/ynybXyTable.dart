import 'dart:convert';
import 'sqliteDb.dart';
import 'package:common_utils/common_utils.dart';

///新约 一年一遍
class YnybXyTable {
  int days;
  List<String> ids = [];
  bool isComplete = false;
  Map<String, String> comments = {};

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
    var db = await DatabaseHelper().db;
    var result = await db
        .query(TABLENAME, where: "days = ?", whereArgs: [getDaysOfDate(date)]);
    YnybXyTable record;
    result.forEach((element) {
      record = YnybXyTable.fromJson(element);
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
