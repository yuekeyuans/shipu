import 'dart:io';
import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:da_ka/mainDir/contentPage/ContentPageByType.dart';
import 'package:da_ka/mainDir/contentPage/contentPageByList.dart';
import 'package:da_ka/mainDir/contentPage/contentPageEntity.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:da_ka/global.dart';

class ContentPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  @override
  void initState() {
    super.initState();
    scanMainDir();
  }

  void scanMainDir() async {
    //根目录文件
    var existFile = await ContentFileInfoTable().queryAll();
    existFile.forEach((element) async {
      if (!await File(element.filepath).exists()) {
        element.remove();
      }
    });
    existFile = await ContentFileInfoTable().queryAll();
    var directory = Directory(SpUtil.getString("MAIN_PATH"));
    directory.list().forEach((e) {
      if (e is File) {
        var path = e.path;
        if (!existFile.any((el) => el.filename == path.split("/").last)) {
          if (suffix.any((element) => path.endsWith(element))) {
            ContentFileInfoTable.fromPath(path).insert();
          }
        }
      }
    });
  }

  String value = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(child: AppBar(title: Text("文件列表")), preferredSize: Size.fromHeight(APPBAR_HEIGHT)),
      body: ContentPageEntity.fromSp().listType == ContentPageEntityType.list ? ContentPageByList() : ContentPageByType(),
    );
  }
}
