import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BibleDatabaseHelper {
  static final BibleDatabaseHelper _instance = BibleDatabaseHelper.internal();
  factory BibleDatabaseHelper() => _instance;
  static Database _db;
  final filename = "bible.db";

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  BibleDatabaseHelper.internal();

  initDb() async {
    String dir = SpUtil.getString("DB_PATH");
    var path = '$dir/$filename';
    print(path);
    if (!File(path).existsSync()) {
      await copyFile();
    }
    var ourDb = await openDatabase(path, version: 1);
    return ourDb;
  }

  Future<File> copyFile() async {
    var writeToFile = (ByteData data, String path) {
      final buffer = data.buffer;
      return new File(path).writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    };

    var bytes = await rootBundle.load("assets/db/$filename");
    var dirs = SpUtil.getString("DB_PATH");
    return writeToFile(bytes, '$dirs/$filename');
  }
}
