import 'dart:convert';

import 'NeeDb.dart';

class NeeOutlineTable {
  static const TABLE_NAME = "outline";
  int id;
  String language;
  int bookIndex;
  int chapter;
  int section;
  String flag;
  String content;
  String mark;
  NeeOutlineTable({
    this.id,
    this.language,
    this.bookIndex,
    this.chapter,
    this.section,
    this.flag,
    this.content,
    this.mark,
  });

  NeeOutlineTable copyWith({
    int id,
    String language,
    int bookIndex,
    int chapter,
    int section,
    String flag,
    String content,
    String mark,
  }) {
    return NeeOutlineTable(
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
      'mark': mark,
    };
  }

  factory NeeOutlineTable.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return NeeOutlineTable(
      id: map['_id'] as int,
      language: map['language'] as String,
      bookIndex: map['book_index'] as int,
      chapter: map['chapter'] as int,
      section: map['section'] as int,
      flag: map['flag'].toString(),
      content: map['content'] as String,
      mark: map['mark'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NeeOutlineTable.fromJson(String source) => NeeOutlineTable.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NeeContentTable(id: $id, language: $language, bookIndex: $bookIndex, chapter: $chapter, section: $section, flag: $flag, content: $content, mark: $mark)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NeeOutlineTable && o.id == id && o.language == language && o.bookIndex == bookIndex && o.chapter == chapter && o.section == section && o.flag == flag && o.content == content && o.mark == mark;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ bookIndex.hashCode ^ chapter.hashCode ^ section.hashCode ^ flag.hashCode ^ content.hashCode ^ mark.hashCode;
  }

  static Future<List<NeeOutlineTable>> queryChapters() async {
    var db = await NeeDb().db;
    var result = await db.query(TABLE_NAME, where: "flag = ? or flag = ?", whereArgs: ["0", "z"]);
    return result.map<NeeOutlineTable>((e) => NeeOutlineTable.fromMap(e)).toList();
  }
}
