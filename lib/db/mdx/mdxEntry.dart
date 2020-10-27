import 'mdxSqlite.dart';

class MdxEntry {
  String id;
  int sortId;
  String tagId;
  String entry;
  String text;
  String mkdown;
  String html;
  String visiable;
  String createdate;
  String lastUpdateDate;
  String lastViewDate;

  static const TABLENAME = "entry";

  MdxEntry({
    this.id,
    this.sortId,
    this.tagId,
    this.entry,
    this.text,
    this.mkdown,
    this.html,
    this.visiable,
    this.createdate,
    this.lastUpdateDate,
    this.lastViewDate,
  });

  MdxEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    sortId = json["sortId"] as int;
    tagId = json["tagId"] as String;
    entry = json["entry"] as String;
    text = json["text"] as String;
    mkdown = json["mkdown"] as String;
    html = json["html"] as String;
    visiable = json['visiable'] as String;
    createdate = json['createdate'] as String;
    lastUpdateDate = json["lastUpdateDate"] as String;
    lastViewDate = json["lastViewDate"] as String;
  }

  MdxEntry.fromSql(Map<String, dynamic> json) {
    id = json['id'] as String;
    sortId = json["sortId"] as int;
    tagId = json["tagId"] as String;
    entry = json["entry"] as String;
    text = json["text"] as String;
    mkdown = json["mkdown"] as String;
    html = json["html"] as String;
    visiable = json['visiable'] as String;
    createdate = json['createdate'] as String;
    lastUpdateDate = json["lastUpdateDate"] as String;
    lastViewDate = json["lastViewDate"] as String;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map["id"] = id;
    map["sortId"] = sortId;
    map["tagId"] = tagId;
    map["entry"] = entry;
    map["text"] = text;
    map["mkdown"] = mkdown;
    map["html"] = html;
    map["visiable"] = visiable;
    map["createdate"] = createdate;
    map["lastUpdateDate"] = lastUpdateDate;
    map["lastViewDate"] = lastViewDate;
    return map;
  }

  Future<List<MdxEntry>> queryAll() async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<MdxEntry> load() async {
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, where: "id = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      var a = MdxEntry.fromSql(result.first);
      html = a.html ?? "";
      text = a.text ?? "";
      return this;
    }
    return null;
  }

  Future<List<MdxEntry>> queryIndexes() async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, columns: ["id", "sortId", "tagId", "entry", "visiable"]);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<List<MdxEntry>> queryIndexesBySearch(String text) async {
    if (text == "" || text == null) {
      return queryIndexes();
    }

    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, columns: ["id", "sortId", "tagId", "entry", "visiable"], where: "entry like ?", whereArgs: ["%" + text + "%"]);
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  Future<MdxEntry> queryFromId(String id) async {
    var db = await MdxDb().db;
    var result = await db.query(TABLENAME, where: "id = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      var a = MdxEntry.fromSql(result.first);
      return a;
    }
    return null;
  }

  Future<List<MdxEntry>> queryIndexesByTag(String tag) async {
    final List<MdxEntry> list = [];
    var db = await MdxDb().db;
    var result = await db.query(
      TABLENAME,
      columns: ["id", "sortId", "tagId", "entry", "visiable"],
      where: "tagId = ?",
      whereArgs: [tag],
    );
    result.forEach((item) {
      list.add(MdxEntry.fromSql(item));
    });
    return list;
  }

  MdxEntry copyWith({
    String id,
    int sortId,
    String tagId,
    String entry,
    String text,
    String mkdown,
    String html,
    String visiable,
    String createdate,
    String lastUpdateDate,
    String lastViewDate,
  }) {
    return MdxEntry(
      id: id ?? this.id,
      sortId: sortId ?? this.sortId,
      tagId: tagId ?? this.tagId,
      entry: entry ?? this.entry,
      text: text ?? this.text,
      mkdown: mkdown ?? this.mkdown,
      html: html ?? this.html,
      visiable: visiable ?? this.visiable,
      createdate: createdate ?? this.createdate,
      lastUpdateDate: lastUpdateDate ?? this.lastUpdateDate,
      lastViewDate: lastViewDate ?? this.lastViewDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sortId': sortId,
      'tagId': tagId,
      'entry': entry,
      'text': text,
      'mkdown': mkdown,
      'html': html,
      'visiable': visiable,
      'createdate': createdate,
      'lastUpdateDate': lastUpdateDate,
      'lastViewDate': lastViewDate,
    };
  }

  factory MdxEntry.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return MdxEntry(
      id: map['id'] as String,
      sortId: map['sortId'] as int,
      tagId: map['tagId'] as String,
      entry: map['entry'] as String,
      text: map['text'] as String,
      mkdown: map['mkdown'] as String,
      html: map['html'] as String,
      visiable: map['visiable'] as String,
      createdate: map['createdate'] as String,
      lastUpdateDate: map['lastUpdateDate'] as String,
      lastViewDate: map['lastViewDate'] as String,
    );
  }

  @override
  String toString() {
    return 'MdxEntry(id: $id, sortId: $sortId, tagId: $tagId, entry: $entry, text: $text, mkdown: $mkdown, html: $html, visiable: $visiable, createdate: $createdate, lastUpdateDate: $lastUpdateDate, lastViewDate: $lastViewDate)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MdxEntry && o.id == id && o.sortId == sortId && o.tagId == tagId && o.entry == entry && o.text == text && o.mkdown == mkdown && o.html == html && o.visiable == visiable && o.createdate == createdate && o.lastUpdateDate == lastUpdateDate && o.lastViewDate == lastViewDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ sortId.hashCode ^ tagId.hashCode ^ entry.hashCode ^ text.hashCode ^ mkdown.hashCode ^ html.hashCode ^ visiable.hashCode ^ createdate.hashCode ^ lastUpdateDate.hashCode ^ lastViewDate.hashCode;
  }
}
