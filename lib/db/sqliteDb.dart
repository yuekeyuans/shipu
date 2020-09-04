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
    var path = '$dir/$filename';
    if (_db == null) {
      if (!File(path).existsSync()) await copyFile();
      _db = await openDatabase(path, version: 1);
    }
    return _db;
  }

  DatabaseHelper.internal();

  Future<File> copyFile() async {
    var writeToFile = (ByteData data, String path) {
      if (!File(path).existsSync()) File(path).createSync();
      return new File(path).writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    };

    var bytes = await rootBundle.load("assets/db/$filename");
    return await writeToFile(bytes, '$dir/$filename');
  }
}
