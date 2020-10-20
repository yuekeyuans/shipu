import 'dart:async';
import 'dart:io';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class MainDb {
  static final MainDb _instance = MainDb.internal();
  factory MainDb() => _instance;
  static Database _db;

  final filename = "clock_in.db";
  final dir = SpUtil.getString("DB_PATH");

  Future<Database> get db async {
    var path = '$dir/$filename';
    if (_db == null) {
      if (!File(path).existsSync()) {
        UtilFunction.copyFile(await rootBundle.load("assets/db/$filename"), '$dir/$filename');
      }
      _db = await openDatabase(path, version: 1);
    }
    return _db;
  }

  MainDb.internal();
}
