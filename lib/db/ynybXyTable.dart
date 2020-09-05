import 'dart:convert';

///新约 一年一遍
class YnybXyTable {
  int days;
  List<String> ids;
  bool isComplete;
  Map<String, String> comments;

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

  YnybXyTable queryByDate(){
    
  }
}
