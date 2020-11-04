import 'dart:convert';

import 'package:da_ka/db/bible/bibleContentTable.dart';

class BibleChapter {
  int bookId;
  int chapterId;
  BibleChapter(
    this.bookId,
    this.chapterId,
  );
  List<BibleContentTable> bibles = [];

  BibleChapter copyWith({
    int bookId,
    int chapterId,
  }) {
    return BibleChapter(
      bookId ?? this.bookId,
      chapterId ?? this.chapterId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'chapterId': chapterId,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'BibleChapter(bookId: $bookId, chapterId: $chapterId)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is BibleChapter && o.bookId == bookId && o.chapterId == chapterId;
  }

  @override
  int get hashCode => bookId.hashCode ^ chapterId.hashCode;
}
