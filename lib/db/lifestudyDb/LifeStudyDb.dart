import 'dart:async';
import 'dart:io';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class LifeStudyDb {
  static final LifeStudyDb _instance = LifeStudyDb.internal();
  factory LifeStudyDb() => _instance;
  static Database _db;

  final filename = "lifestudy.db";

  Future<Database> get db async {
    var dir = SpUtil.getString("DB_PATH");
    var path = '$dir/$filename';
    if (_db == null) {
      if (!File(path).existsSync()) {
        var bytes = await rootBundle.load("assets/db/lifestudy.zip");
        UtilFunction.unzip(bytes.buffer.asUint8List(), dir);
      }
      _db = await openDatabase(path, version: 1);
    }
    return _db;
  }

  LifeStudyDb.internal();
}
