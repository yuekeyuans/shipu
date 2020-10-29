import 'dart:convert';
import 'NeeDb.dart';

class NeeContentTable {
  static const TABLE_NAME = "content";
  int id;
  String language;
  int bookIndex;
  int chapter;
  int section;
  String flag;
  String content;
  String mark;
  NeeContentTable({
    this.id,
    this.language,
    this.bookIndex,
    this.chapter,
    this.section,
    this.flag,
    this.content,
    this.mark,
  });

  NeeContentTable copyWith({
    int id,
    String language,
    int bookIndex,
    int chapter,
    int section,
    String flag,
    String content,
    String mark,
  }) {
    return NeeContentTable(
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

  factory NeeContentTable.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return NeeContentTable(
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

  factory NeeContentTable.fromJson(String source) => NeeContentTable.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NeeContentTable(id: $id, language: $language, bookIndex: $bookIndex, chapter: $chapter, section: $section, flag: $flag, content: $content, mark: $mark)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NeeContentTable && o.id == id && o.language == language && o.bookIndex == bookIndex && o.chapter == chapter && o.section == section && o.flag == flag && o.content == content && o.mark == mark;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ bookIndex.hashCode ^ chapter.hashCode ^ section.hashCode ^ flag.hashCode ^ content.hashCode ^ mark.hashCode;
  }

  //查找文章
  Future<List<NeeContentTable>> queryChapter({int bookIndex = 1, int chapter = 1}) async {
    String sql = """
      select * from outline where outline.book_index = ? and outline.chapter = ? union 
      select * from content where content.book_index = ? and content.chapter = ? order by section
    """;
    var db = await NeeDb().db;
    var result = await db.rawQuery(sql, [bookIndex, chapter, bookIndex, chapter]);
    return result.map((e) => NeeContentTable.fromMap(e)).toList();
  }
}
