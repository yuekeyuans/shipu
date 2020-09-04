import 'package:da_ka/subPage/functions/dakaFunction/dakaFunctionPage.dart';
import 'package:da_ka/subPage/functions/encriptionFunction/encriptionFunctionPage.dart';
import 'package:da_ka/subPage/functions/isiloFunction/isiloFunction.dart';
import 'package:da_ka/subPage/functions/splashFunction/splashFunction.dart';
import 'package:da_ka/subPage/functions/wifiFunction/wifiFunctionPage.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import 'functions/backupFunction/backupFunctionPage.dart';
import 'functions/scanFileFunction/scanFile.dart';
import 'functions/storageFunction/storageFunctionPage.dart';

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
          title: Text("给别人分享这个软件"),
          leading: Icon(Icons.share),
          onTap: () => routePush(BackUpAppPage()),
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text("说明"), content: Text("备份文件"));
                  }))),
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
        enabled: false,
        leading: Icon(Icons.wifi),
        onTap: () => routePush(WifiShareFunctionPage()),
      ),
      ListTile(
          title: Text("加密文件"),
          leading: Icon(Icons.enhanced_encryption),
          onTap: () => routePush(EncryptionFunctionPage()),
          enabled: true,
          trailing: GestureDetector(
              child: Icon(Icons.info),
              onTap: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("说明"),
                      content: Text("简单加密文件,方便公共网络分享"),
                    );
                  }))),
      ListTile(
          title: Text("打卡功能"),
          leading: Icon(Icons.speaker_phone),
          onTap: () => routePush(DaKaFunctionPage()),
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
          enabled: true,
          title: Text("存储管理"),
          leading: Icon(Icons.storage),
          onTap: () => routePush(StorageFunctionPage()),
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
