import 'dart:convert';

class NeeOutlineTable {
  static const TABLE_NAME = "outline";
  int id;
  String language;
  int bookIndex;
  int chapter;
  int section;
  String flag;
  String outline;
  String mark;
  NeeOutlineTable({
    this.id,
    this.language,
    this.bookIndex,
    this.chapter,
    this.section,
    this.flag,
    this.outline,
    this.mark,
  });

  NeeOutlineTable copyWith({
    int id,
    String language,
    int bookIndex,
    int chapter,
    int section,
    String flag,
    String outline,
    String mark,
  }) {
    return NeeOutlineTable(
      id: id ?? this.id,
      language: language ?? this.language,
      bookIndex: bookIndex ?? this.bookIndex,
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
      'book_index': bookIndex,
      'chapter': chapter,
      'section': section,
      'flag': flag,
      'outline': outline,
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
      flag: map['flag'] as String,
      outline: map['outline'] as String,
      mark: map['mark'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NeeOutlineTable.fromJson(String source) => NeeOutlineTable.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NeeOutlineTable(id: $id, language: $language, bookIndex: $bookIndex, chapter: $chapter, section: $section, flag: $flag, outline: $outline, mark: $mark)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NeeOutlineTable && o.id == id && o.language == language && o.bookIndex == bookIndex && o.chapter == chapter && o.section == section && o.flag == flag && o.outline == outline && o.mark == mark;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ bookIndex.hashCode ^ chapter.hashCode ^ section.hashCode ^ flag.hashCode ^ outline.hashCode ^ mark.hashCode;
  }
}
