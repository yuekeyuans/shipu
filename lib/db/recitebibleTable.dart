class ReciteBibleTable {
  List<String> ids = [];
  DateTime date = DateTime.now();
  bool isComplete = false;
  bool isDelay = false;

  ReciteBibleTable();

  ReciteBibleTable.fromJson(Map<String, String> map) {
    ids = map["ids"].toString().split(",");
    
  }

  toJson() {
    var map = Map<String, String>();
    map["ids"] = listToString(ids);
    map["date"] = date.toIso8601String();
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
