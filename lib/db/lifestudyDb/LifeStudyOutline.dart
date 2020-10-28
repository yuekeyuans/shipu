import 'dart:convert';

import 'package:da_ka/db/lifestudyDb/LifeStudyDb.dart';

class LifeStudyOutline {
  static const String TABLE_NAME = "outline";
  int id;
  String language;
  int book_index;
  int chapter;
  int section;
  int flag;
  String outline;
  String mark;
  LifeStudyOutline({
    this.id,
    this.language,
    this.book_index,
    this.chapter,
    this.section,
    this.flag,
    this.outline,
    this.mark,
  });

  LifeStudyOutline copyWith({
    int id,
    String language,
    int book_index,
    int chapter,
    int section,
    int flag,
    String outline,
    String mark,
  }) {
    return LifeStudyOutline(
      id: id ?? this.id,
      language: language ?? this.language,
      book_index: book_index ?? this.book_index,
      chapter: chapter ?? this.chapter,
      section: section ?? this.section,
      flag: flag ?? this.flag,
      outline: outline ?? this.outline,
      mark: mark ?? this.mark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'language': language,
      'book_index': book_index,
      'chapter': chapter,
      'section': section,
      'flag': flag,
      'outline': outline,
      'mark': mark,
    };
  }

  factory LifeStudyOutline.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return LifeStudyOutline(
      id: map['_id'] as int,
      language: map['language'] as String,
      book_index: map['book_index'] as int,
      chapter: map['chapter'] as int,
      section: map['section'] as int,
      flag: map['flag'] as int,
      outline: map['outline'] as String,
      mark: map['mark'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LifeStudyOutline.fromJson(String source) => LifeStudyOutline.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LifeStudyOutline(id: $id, language: $language, book_index: $book_index, chapter: $chapter, section: $section, flag: $flag, outline: $outline, mark: $mark)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LifeStudyOutline && o.id == id && o.language == language && o.book_index == book_index && o.chapter == chapter && o.section == section && o.flag == flag && o.outline == outline && o.mark == mark;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ book_index.hashCode ^ chapter.hashCode ^ section.hashCode ^ flag.hashCode ^ outline.hashCode ^ mark.hashCode;
  }

  //查询所有名称
  static Future<List<LifeStudyOutline>> queryAllChapterName() async {
    var lst = <LifeStudyOutline>[];
    var db = await LifeStudyDb().db;
    var result = await db.query(TABLE_NAME, where: "flag = ?", whereArgs: [0]);
    result.forEach((element) {
      lst.add(LifeStudyOutline.fromMap(element));
    });
    return lst;
  }
}
