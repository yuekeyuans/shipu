import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:da_ka/views/mdxView/mdxView_native.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';

class DescriptionFunction extends StatefulWidget {
  @override
  _DescriptionFunctionState createState() => _DescriptionFunctionState();
}

class _DescriptionFunctionState extends State<DescriptionFunction> {
  String info = """
-  语音朗读
-  一年一遍
-  生命读经
-  倪文集
-  pdf, word文件
-  自定义词典文件
-  isilo, 快传,自身软件管理
-  分享功能
-  加密功能
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("说明")),
        body: Container(
            color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text("版本"),
                  subtitle: Text("第一版"),
                ),
                Divider(height: 1.0),
                ListTile(
                  leading: Icon(Icons.help),
                  title: Text("帮助文档"),
                  subtitle: Text("点击可查看如何使用软件"),
                  onTap: openHelpDoc,
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(height: 1.0),
                ListTile(
                  leading: Icon(Icons.update),
                  title: Text("实现功能"),
                  subtitle: Text(info),
                ),
              ],
            )));
  }

  //打开帮助文档
  Future<void> openHelpDoc() async {
    String dir = SpUtil.getString("DB_PATH");
    var path = '$dir/help.dict';
    if (!File(path).existsSync()) {
      var bytes = await rootBundle.load("assets/db/help.zip");
      UtilFunction.unzip(bytes.buffer.asUint8List(), SpUtil.getString("DB_PATH"));
    }
    routePush(MdxViewer(path));
  }
}
