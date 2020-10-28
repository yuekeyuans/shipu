import 'dart:convert';

import 'package:da_ka/db/lifestudyDb/LifeStudyDb.dart';

class LifeStudyBookName {
  static const String TABLE_NAME = "book_name";
  bool isFold = true;
  int id;
  String language;
  int bookIndex;
  String name;
  String acronymName;
  LifeStudyBookName({
    this.id,
    this.language,
    this.bookIndex,
    this.name,
    this.acronymName,
  });

  LifeStudyBookName copyWith({
    int id,
    String language,
    int bookIndex,
    String name,
    String acronymName,
  }) {
    return LifeStudyBookName(
      id: id ?? this.id,
      language: language ?? this.language,
      bookIndex: bookIndex ?? this.bookIndex,
      name: name ?? this.name,
      acronymName: acronymName ?? this.acronymName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'language': language,
      'book_index': bookIndex,
      'name': name,
      'acronym_name': acronymName,
    };
  }

  factory LifeStudyBookName.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return LifeStudyBookName(
      id: map['_id'] as int,
      language: map['language'] as String,
      bookIndex: map['book_index'] as int,
      name: map['name'] as String,
      acronymName: map['acronym_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LifeStudyBookName.fromJson(String source) => LifeStudyBookName.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LifeStudyBookName(id: $id, language: $language, bookIndex: $bookIndex, name: $name, acronymName: $acronymName)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LifeStudyBookName && o.id == id && o.language == language && o.bookIndex == bookIndex && o.name == name && o.acronymName == acronymName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ bookIndex.hashCode ^ name.hashCode ^ acronymName.hashCode;
  }

  static Future<List<LifeStudyBookName>> queryAllBookNames() async {
    var db = await LifeStudyDb().db;
    var result = await db.query(TABLE_NAME, orderBy: "book_index asc");
    return result.map<LifeStudyBookName>((e) => LifeStudyBookName.fromMap(e)).toList();
  }
}
