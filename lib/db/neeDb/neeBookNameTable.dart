import 'dart:convert';

class NeeBookNameTable {
  static const TABLE_NAME = "book_name";
  int id;
  String language;
  int bookIndex;
  String bookNumber;
  String name;
  String mark;
  NeeBookNameTable({
    this.id,
    this.language,
    this.bookIndex,
    this.bookNumber,
    this.name,
    this.mark,
  });

  NeeBookNameTable copyWith({
    int id,
    String language,
    int bookIndex,
    String bookNumber,
    String name,
    String mark,
  }) {
    return NeeBookNameTable(
      id: id ?? this.id,
      language: language ?? this.language,
      bookIndex: bookIndex ?? this.bookIndex,
      bookNumber: bookNumber ?? this.bookNumber,
      name: name ?? this.name,
      mark: mark ?? this.mark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'language': language,
      'book_index': bookIndex,
      'book_number': bookNumber,
      'name': name,
      'mark': mark,
    };
  }

  factory NeeBookNameTable.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return NeeBookNameTable(
      id: map['_id'] as int,
      language: map['language'] as String,
      bookIndex: map['book_index'] as int,
      bookNumber: map['book_number'] as String,
      name: map['name'] as String,
      mark: map['mark'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NeeBookNameTable.fromJson(String source) => NeeBookNameTable.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NeeBookNameTable(id: $id, language: $language, bookIndex: $bookIndex, bookNumber: $bookNumber, name: $name, mark: $mark)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NeeBookNameTable && o.id == id && o.language == language && o.bookIndex == bookIndex && o.bookNumber == bookNumber && o.name == name && o.mark == mark;
  }

  @override
  int get hashCode {
    return id.hashCode ^ language.hashCode ^ bookIndex.hashCode ^ bookNumber.hashCode ^ name.hashCode ^ mark.hashCode;
  }
}
