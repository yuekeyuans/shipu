class LifeStudyRecord {
  int id;
  String language;
  int bookIndex;
  int chapter;
  int section;
  String flag;
  String content;
  LifeStudyRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    language = json["language"] as String;
    bookIndex = json["book_index"] as int;
    chapter = json["chapter"] as int;
    section = json["section"] as int;
    flag = json["flag"].toString();
    content = json["outline"] as String;
  }
}
