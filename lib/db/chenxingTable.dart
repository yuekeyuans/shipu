class ChenXingTable {
  static const TABLE_NAME = "chenxing";
  String id;
  int day;
  String date;
  String content;
  String voice;
  bool hasread;
  String links;
  DateTime readtime;

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

  ChenXingTable.fromSql() {}

  ChenXingTable.toJson() {}
}
