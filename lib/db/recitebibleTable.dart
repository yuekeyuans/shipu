import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bibleTable.dart';
import 'package:da_ka/db/sqliteDb.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:sqflite/sqflite.dart';

//该表存在于 clock_in.db
class ReciteBibleTable {
  List<String> ids = [];
  DateTime date = DateTime.now();
  bool isComplete = false;
  bool isDelay = false;

  static const TABLENAME = "recitebible";

  ReciteBibleTable();

  ReciteBibleTable.fromJson(Map<String, dynamic> map) {
    ids = map["ids"].toString().split(",");
    date = DateTime.parse(map["date"]);
    isComplete = map["iscomplete"] == true.toString();
    isDelay = map["isDelay"] == true.toString();
  }

  toJson() {
    var map = Map<String, String>();
    map["ids"] = listToString(ids);
    map["date"] = DateUtil.formatDate(date, format: DateFormats.y_mo_d);
    map["iscomplete"] = isComplete.toString();
    map["isdelay"] = isDelay.toString();
    return map;
  }

  Future<ReciteBibleTable> queryByDay(DateTime date) async {
    ReciteBibleTable record;
    if (!await existDateRecord(date)) {
      await createDateRecord();
    }
    var db = await DatabaseHelper().db;
    var result = await db.query(TABLENAME,
        where: "date = ?",
        whereArgs: [DateUtil.formatDate(date, format: DateFormats.y_mo_d)]);

    result.forEach((element) {
      record = ReciteBibleTable.fromJson(element);
    });
    return record;
  }

  Future<bool> existDateRecord(DateTime date) async {
    var db = await DatabaseHelper().db;
    var result = Sqflite.firstIntValue(await db.query(TABLENAME,
        columns: ["count(*)"],
        where: "date = ?",
        whereArgs: [DateUtil.formatDate(date, format: DateFormats.y_mo_d)]));
    return result != 0;
  }

  Future<void> createDateRecord() async {
    var entity = ReciteBibleEntity.fromSp();
    var id = await BookName().queryBookId(entity.currentBook);
    var minMax = await BibleTable().queryMinMaxId(id);
    var record = ReciteBibleTable();
    var lastDay = DateTime.now().add(Duration(days: -1));
    var lastNumber = minMax.first;
    if (await existDateRecord(lastDay)) {
      var last = await queryByDay(lastDay);
      lastNumber = int.parse(last.ids.last.toString()) + 1;
    }
    var ids = <String>[];
    for (int i = 0;
        i < entity.verseOfDay && lastNumber + i <= minMax.last;
        i++) {
      ids.add((lastNumber + i).toString());
    }
    record.ids = ids;
    record.save();
  }

  Future<void> save() async {
    var db = await DatabaseHelper().db;
    await db.insert(TABLENAME, this.toJson());
  }

  String listToString(List<String> strs) {
    if (strs == null) {
      return "";
    }
    return strs.join(",");
  }
}