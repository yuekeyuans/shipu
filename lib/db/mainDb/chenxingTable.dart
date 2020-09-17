class ChenXingTable {
  ChenXingTable(
      {this.id,
      this.day,
      this.date,
      this.content,
      this.voice,
      this.hasread,
      this.links,
      this.readtime});

  ChenXingTable.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    day = json['day'];
    date = json['date'];
    content = json['content'];
    voice = json['voice'];
    hasread = json['hasread'] == 1 ? true : false;
  }

  //TODO:
  ChenXingTable.fromSql();

  ChenXingTable.toJson();

  static const TABLE_NAME = "chenxing";

  String content;
  String date;
  int day;
  bool hasread;
  String id;
  String links;
  DateTime readtime;
  String voice;
}
