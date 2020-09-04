import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  static Database _db;
  final filename = "clock_in.db";
  String dir = SpUtil.getString("DB_PATH");
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    var path = '$dir/$filename';
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
    return writeToFile(bytes, '$dir/$filename');
  }
}
