class LifeStudyRecord {
  int id;
  String language;
  int bookIndex;
  int chapter;
  int section;
  String flag;
  String content;
  LifeStudyRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    language = json["language"];
    bookIndex = json["book_index"];
    chapter = json["chapter"];
    section = json["section"];
    flag = json["flag"].toString();
    content = json["outline"];
  }
}
