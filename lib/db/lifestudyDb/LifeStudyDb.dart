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

  Future<Database> get db async {
    var dir = SpUtil.getString("DB_PATH");
    String fileName = "lifestudy.db";
    var path = '$dir/$fileName';
    if (_db == null) {
      if (!File(path).existsSync()) {
        UtilFunction.copyFile(await rootBundle.load("assets/db/$fileName"), '$dir/$fileName');
      }
      _db = await openDatabase(path, version: 1);
    }
    return _db;
  }

  LifeStudyDb.internal();
}
