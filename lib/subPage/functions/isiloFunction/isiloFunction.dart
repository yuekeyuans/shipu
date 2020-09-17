import 'package:da_ka/subPage/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sharePdbFunction.dart';
import 'package:nav_router/nav_router.dart';
import 'scanPdbFunction.dart';

class IsiloFunctionPage extends StatefulWidget {
  @override
  _IsiloFunctionPageState createState() => _IsiloFunctionPageState();
}

class _IsiloFunctionPageState extends State<IsiloFunctionPage> {
  MethodChannel channel;
  var packageName = "com.dcco.app.iSilo";
  var isNotInstalled = true;

  @override
  void initState() {
    super.initState();
    channel = const MethodChannel("com.example.clock_in/isilo");
    isinstallIsilo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("isilo 操作"),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text("安装 isilo"),
              onTap: () => installIsilo(),
              enabled: isNotInstalled,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text("打开 isilo"),
              enabled: !isNotInstalled,
              onTap: () => invokeIsilo(),
            ),
            Divider(height: 4),
            ListTile(
              leading: Icon(Icons.store),
              title: Text("扫描拷贝isilo 文件"),
              onTap: () => routePush(ScanPdbFunction()),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("分享pdb 文件"),
              onTap: () => routePush(SharePdbFunction()),
            )
          ],
        ),
      ),
    );
  }

  Future<void> isinstallIsilo() async {
    await channel.invokeMethod("isInstalled").then((value) {
      print(value);
      if (value.toString().contains(packageName)) {
        setState(() {
          isNotInstalled = false;
        });
      } else {
        setState(() {
          isNotInstalled = true;
        });
      }
    });
  }

  installIsilo() async {
    var dirName = SpUtil.getString("TEMP_PATH");
    UtilFunction.copyFile(
        await rootBundle.load("assets/apk/isilo.apk"), '$dirName/isilo.apk');
    channel.invokeMethod("installIsilo", {"path": '$dirName/isilo.apk'}).then(
        (value) => isinstallIsilo());
  }

  invokeIsilo() {
    channel.invokeMethod("startIsilo");
  }
}
