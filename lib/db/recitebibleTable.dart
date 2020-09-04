import 'package:common_utils/common_utils.dart';

class ReciteBibleTable {
  List<String> ids = [];
  DateTime date = DateTime.now();
  bool isComplete = false;
  bool isDelay = false;

  ReciteBibleTable();

  ReciteBibleTable.fromJson(Map<String, dynamic> map) {
    ids = map["ids"].toString().split(",");
    date = DateTime.parse(map["date"]);
    isComplete = map["iscomplete"] == true.toString();
    isDelay = map["isDelay"] == true.toString();
  }

  toJson() {
    var map = Map<String, String>();
    map["ids"] = listToString(ids);
    map["date"] = DateUtil.formatDate(date, format: DateFormats.y_mo_d);
    map["iscomplete"] = isComplete.toString();
    map["isdelay"] = isDelay.toString();
    return map;
  }

  String listToString(List<String> list) {
    if (list == null) {
      return null;
    }
    var result = "";
    var first = true;
    for (String string in list) {
      if (first) {
        first = false;
      } else {
        result = "$result,";
      }
      result = "$string";
    }
    return result.toString();
  }
}
