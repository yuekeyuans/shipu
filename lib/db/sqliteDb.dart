import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;
  final filename = "clock_in.db";

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    String dir =
        (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
    var path = '$dir/zhuhuifu/clock_in.db';
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

    var bytes = await rootBundle.load("assets/db/clock_in.db");
    String dir =
        (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
    var dirs = Directory("$dir/zhuhuifu");
    if (!(await dirs.exists())) {
      dirs.createSync();
    }
    return writeToFile(bytes, '$dir/zhuhuifu/$filename');
  }
}
