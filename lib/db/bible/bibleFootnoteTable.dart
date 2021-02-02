import 'dart:convert';

import 'package:da_ka/db/bible/bibleDb.dart';

class BibleFotnoteTable {
  static const TABLE_NAME = "footnote";
  int id;
  int bookIndex;
  int chapter;
  int section;
  int flag;
  int location;
  int seq;
  String note;
  BibleFotnoteTable({
    this.id,
    this.bookIndex,
    this.chapter,
    this.section,
    this.flag,
    this.location,
    this.seq,
    this.note,
  });

  BibleFotnoteTable copyWith({
    int id,
    int bookIndex,
    int chapter,
    int section,
    int flag,
    int location,
    int seq,
    String note,
  }) {
    return BibleFotnoteTable(
      id: id ?? this.id,
      bookIndex: bookIndex ?? this.bookIndex,
      chapter: chapter ?? this.chapter,
      section: section ?? this.section,
      flag: flag ?? this.flag,
      location: location ?? this.location,
      seq: seq ?? this.seq,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'book_index': bookIndex,
      'chapter': chapter,
      'section': section,
      'flag': flag,
      'location': location,
      'seq': seq,
      'note': note,
    };
  }

  factory BibleFotnoteTable.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return BibleFotnoteTable(
      id: map['_id'] as int,
      bookIndex: map['book_index'] as int,
      chapter: map['chapter'] as int,
      section: map['section'] as int,
      flag: map['flag'] as int,
      location: map['location'] as int,
      seq: map['seq'] as int,
      note: map['note'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BibleFotnoteTable.fromJson(String source) => BibleFotnoteTable.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BibleFotnoteTable(id: $id, bookIndex: $bookIndex, chapter: $chapter, section: $section, flag: $flag, location: $location, seq: $seq, note: $note)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is BibleFotnoteTable && o.id == id && o.bookIndex == bookIndex && o.chapter == chapter && o.section == section && o.flag == flag && o.location == location && o.seq == seq && o.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^ bookIndex.hashCode ^ chapter.hashCode ^ section.hashCode ^ flag.hashCode ^ location.hashCode ^ seq.hashCode ^ note.hashCode;
  }

  static Future<List<BibleFotnoteTable>> queryByChaptersAndSections(int bookIndex, Map<int, List<int>> maps) async {
    //build sql
    //这里有一节圣经分成多节的问题，所以需要特殊处理下
    var sql = "select * from ${TABLE_NAME} where book_index = $bookIndex and (";
    List<String> wheres = [];
    maps.forEach((key, value) {
      List<int> _val = [];
      value.forEach((e) {
        if (!_val.contains(e)) {
          _val.add(e);
        }
      });
      wheres.add("(chapter = $key and section in (${_val.join(',')}))");
    });
    sql = sql + wheres.join(" or ") + ")";
    print(sql);
    var db = await BibleDb().db;
    var result = await db.rawQuery(sql);
    return result.map<BibleFotnoteTable>((e) => BibleFotnoteTable.fromMap(e)).toList();
  }
}
