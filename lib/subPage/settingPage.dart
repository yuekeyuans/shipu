import 'package:da_ka/subPage/functions/isiloFunction/isiloFunction.dart';
import 'package:da_ka/subPage/functions/splashFunction/splashFunction.dart';
import 'package:da_ka/subPage/functions/wifiFunction/wifiFunctionPage.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import 'functions/scanFileFunction/scanFile.dart';

class FunctionPage extends StatefulWidget {
  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(children: <Widget>[
      ListTile(
          title: Text("扫描文件夹"),
          leading: Icon(Icons.scanner),
          onTap: () => routePush(ScanFilesPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text(
                          "扫描微信，QQ,浏览器等下载的文件，并将符合要求的文件列出。\n可以选择相应的文件，添加到程序目录中使用。"),
                    );
                  }))),
      ListTile(
          title: Text("启动页"),
          leading: Icon(Icons.screen_share),
          onTap: () => routePush(SplashFunctionPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("管理程序的启动页"),
                    );
                  }))),
      ListTile(
          title: Text("isilo 操作"),
          leading: CircleAvatar(
            radius: 13,
            backgroundColor: Colors.transparent,
            child: Image.asset('assets/icon/isilo.png'),
          ),
          onTap: () => routePush(IsiloFunctionPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("isilo 操作"),
                    );
                  }))),
      ListTile(
        title: Text("分享"),
        leading: Icon(Icons.wifi),
        onTap: () => routePush(WifiShareFunctionPage()),
      ),
      ListTile(
          title: Text("听书模式"),
          leading: Icon(Icons.speaker_phone),
          onTap: () => routePush(ScanFilesPage()),
          enabled: false,
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("对于不识字，或者视力不好者，可以开启此模式。"),
                    );
                  }))),
      ListTile(
          enabled: false,
          title: Text("存储管理"),
          leading: Icon(Icons.storage),
          onTap: () => routePush(ScanFilesPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("管理程序使用的存储空间。"),
                    );
                  }))),
      ListTile(
          enabled: false,
          title: Text("闹钟"),
          leading: Icon(Icons.storage),
          onTap: () => routePush(ScanFilesPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("管理程序使用的存储空间。"),
                    );
                  }))),
      ListTile(
          enabled: false,
          title: Text("内容设置"),
          leading: Icon(Icons.storage),
          onTap: () => routePush(ScanFilesPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("管理程序使用的存储空间。"),
                    );
                  }))),
    ]));
  }
}
