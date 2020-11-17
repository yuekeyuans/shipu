import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';

class MarkEntity {
  /// 'bible', 'smdj', 'nee'
  String type;

  ///背景色
  Color bgColor;

  ///文字颜色
  Color textColor;

  ///笔记
  List<String> notes = [];

  ///重点标记,后面有下划线
  List<int> keyNote = [];

  MarkEntity({
    this.type,
    this.bgColor,
    this.textColor,
    this.notes,
    this.keyNote,
  });

  MarkEntity copyWith({
    String type,
    Color bgColor,
    Color textColor,
    List<String> notes,
    List<int> keyNote,
  }) {
    return MarkEntity(
      type: type ?? this.type,
      bgColor: bgColor ?? this.bgColor,
      textColor: textColor ?? this.textColor,
      notes: notes ?? this.notes,
      keyNote: keyNote ?? this.keyNote,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'bgColor': bgColor == null ? bgColor.value : -1,
      'textColor': textColor == null ? textColor.value : -1,
      'notes': notes,
      'keyNote': keyNote,
    };
  }

  factory MarkEntity.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
    var bg = map['bgColor'] as int;
    var text = map['textColor'] as int;
    return MarkEntity(
      type: map['type'] as String,
      bgColor: bg != -1 ? Color(bg) : null,
      textColor: text != -1 ? Color(text) : null,
      notes: List<String>.from(map['notes'] as List),
      keyNote: List<int>.from(map['keyNote'] as List),
    );
  }

  String toJson() => json.encode(toMap());

  factory MarkEntity.fromJson(String source) => MarkEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MarkEntity(type: $type, bgColor: $bgColor, textColor: $textColor, notes: $notes, keyNote: $keyNote)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is MarkEntity && o.type == type && o.bgColor == bgColor && o.textColor == textColor && listEquals(o.notes, notes) && listEquals(o.keyNote, keyNote);
  }

  @override
  int get hashCode {
    return type.hashCode ^ bgColor.hashCode ^ textColor.hashCode ^ notes.hashCode ^ keyNote.hashCode;
  }
}
