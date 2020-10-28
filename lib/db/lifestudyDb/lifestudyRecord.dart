import 'dart:convert';

import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';

import 'LifeStudyDb.dart';

class LifeStudyRecord {
  int id;
  String language;
  int bookIndex;
  int chapter;
  int section;
  String flag;
  String content;
  String mark;
  LifeStudyRecord({
    this.id,
    this.language,
    this.bookIndex,
    this.chapter,
    this.section,
    this.flag,
    this.content,
    this.mark,
  });

  LifeStudyRecord copyWith({
    int id,
    String language,
    int bookIndex,
    int chapter,
    int section,
    String flag,
    String content,
    String mark,
  }) {
    return LifeStudyRecord(
      id: id ?? this.id,
      language: language ?? this.language,
      bookIndex: bookIndex ?? this.bookIndex,
      chapter: chapter ?? this.chapter,
      section: section ?? this.section,
      flag: flag ?? this.flag,
      content: content ?? this.content,
      mark: mark ?? this.mark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'language': language,
      'book_index': bookIndex,
      'chapter': chapter,
      'section': section,
      'flag': flag,
      'content': content,
      "mark": mark,
    };
  }

  factory LifeStudyRecord.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return LifeStudyRecord(
      id: map['_id'] as int,
      language: map['language'] as String,
      bookIndex: map['book_index'] as int,
      chapter: map['chapter'] as int,
      section: map['section'] as int,
      flag: map['flag'].toString(),
      content: map['content'] as String,
      mark: map["mark"] as String,
    );
  }

  String toJson() => json.encode(toMap());

  LifeStudyRecord.fromJson(Map<String, dynamic> json) {
    id = json['_id'] as int;
    language = json["language"] as String;
    bookIndex = json["book_index"] as int;
    chapter = json["chapter"] as int;
    section = json["section"] as int;
    flag = json["flag"].toString();
    content = json["outline"] as String;
    mark = json["mark"] as String;
  }

  @override
  String toString() {
    return 'LifeStudyRecord(id: $id, language: $language, bookIndex: $bookIndex, chapter: $chapter, section: $section, flag: $flag, content: $content, mark: $mark)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LifeStudyRecord && o.id == id && o.language == language && o.bookIndex == bookIndex && o.chapter == chapter && o.section == section && o.flag == flag && o.content == content && mark == o.mark;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ bookIndex.hashCode ^ chapter.hashCode ^ section.hashCode ^ flag.hashCode ^ content.hashCode ^ mark.hashCode;
  }

  Future<void> setMarked(String info) async {
    mark = info;
    var db = await LifeStudyDb().db;
    var tableName = UtilFunction.isNumeric(flag) ? "outline" : "content";
    await db.update(tableName, toMap(), where: "_id = ?", whereArgs: [id]);
  }
}
