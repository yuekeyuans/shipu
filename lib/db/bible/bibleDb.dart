import 'dart:async';
import 'dart:io';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class BibleDb {
  static final BibleDb _instance = BibleDb.internal();
  factory BibleDb() => _instance;
  static Database _db;
  final filename = "bible.db";

  Future<Database> get db async {
    _db ??= await initDb();
    return _db;
  }

  BibleDb.internal();

  Future<Database> initDb() async {
    String dir = SpUtil.getString("DB_PATH");
    var path = '$dir/$filename';
    if (!File(path).existsSync()) {
      //await copyFile();
      var bytes = await rootBundle.load("assets/db/bible.zip");
      UtilFunction.unzip(bytes.buffer.asUint8List(), SpUtil.getString("DB_PATH"));
    }
    var ourDb = await openDatabase(path, version: 1);
    return ourDb;
  }
}
