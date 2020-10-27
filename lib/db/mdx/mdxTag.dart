import 'dart:convert';

import 'mdxSqlite.dart';

class MdxTag {
  static const String TAG_ID_PARENT = "0";
  static const String TAG_ID_NULL = "-1";
  static const String TAG_ID_PLUGIN = "plugin_2";
  static const String TABLE_NAME = "tag";

  String id;
  int sortId;
  String name;
  int size;
  String type;
  String parentId;
  bool locked;
  bool fold;
  MdxTag({
    this.id,
    this.sortId,
    this.name,
    this.size,
    this.type,
    this.parentId,
    this.locked,
    this.fold,
  });

  MdxTag copyWith({
    String id,
    int sortId,
    String name,
    int size,
    String type,
    String parentId,
    bool locked,
    bool fold,
  }) {
    return MdxTag(
      id: id ?? this.id,
      sortId: sortId ?? this.sortId,
      name: name ?? this.name,
      size: size ?? this.size,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      locked: locked ?? this.locked,
      fold: fold ?? this.fold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sortId': sortId,
      'name': name,
      'size': size,
      'type': type,
      'parentId': parentId,
      'locked': locked ? "yes" : "no",
      'fold': fold ? "yes" : "no",
    };
  }

  factory MdxTag.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return MdxTag(
      id: map['id'] as String,
      sortId: map['sortId'] as int,
      name: map['name'] as String,
      size: map['size'] as int,
      type: map['type'] as String,
      parentId: map['parentId'] as String,
      locked: map['locked'] == "yes",
      fold: map['fold'] == "yes",
    );
  }

  String toJson() => json.encode(toMap());

  factory MdxTag.fromJson(String source) => MdxTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MdxTag(id: $id, sortId: $sortId, name: $name, size: $size, type: $type, parentId: $parentId, locked: $locked, fold: $fold)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is MdxTag && o.id == id && o.sortId == sortId && o.name == name && o.size == size && o.type == type && o.parentId == parentId && o.locked == locked && o.fold == fold;
  }

  @override
  int get hashCode {
    return id.hashCode ^ sortId.hashCode ^ name.hashCode ^ size.hashCode ^ type.hashCode ^ parentId.hashCode ^ locked.hashCode ^ fold.hashCode;
  }

  Future<List<MdxTag>> queryAllTags() async {
    var tags = <MdxTag>[];
    var db = await MdxDb().db;
    var result = await db.query(TABLE_NAME);
    result.forEach((element) {
      tags.add(MdxTag.fromMap(element));
    });
    return tags;
  }

  Future<List<MdxTag>> queryTopTags() async {
    var tags = <MdxTag>[];
    var db = await MdxDb().db;
    var result = await db.query(TABLE_NAME, where: "parentId = ?", whereArgs: [TAG_ID_PARENT]);
    result.forEach((element) {
      return tags.add(MdxTag.fromMap(element));
    });
    return tags;
  }

  Future<List<MdxTag>> queryTagsByParent(String parent) async {
    var tags = <MdxTag>[];
    var db = await MdxDb().db;
    var result = await db.query(TABLE_NAME, where: "parentId = ?", whereArgs: [parent]);
    result.forEach((element) {
      return tags.add(MdxTag.fromMap(element));
    });
    return tags;
  }

  Future<MdxTag> queryTagById(String id) async {
    var db = await MdxDb().db;
    var result = await db.query(TABLE_NAME, where: "id = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      return MdxTag.fromMap(result.first);
    }
    return null;
  }
}
