import 'dart:async';
import 'package:sqflite/sqflite.dart';

class MdxDb {
  factory MdxDb() => _instance;

  static final MdxDb _instance = MdxDb.internal();

  static String filePath = "";

  static Database _db;

  MdxDb.internal();

  MdxDb setPath(String path) {
    filePath = path;
    return this;
  }

  Future<Database> get db async {
    if (_db == null || _db.path != filePath) {
      await closeDb();
      _db = await initDb();
    }
    return _db;
  }

  initDb() async {
    var ourDb = await openDatabase(filePath, version: 1);
    return ourDb;
  }

  closeDb() async {
    if (_db != null) {
      await _db.close();
      _db = null;
    }
  }
}
