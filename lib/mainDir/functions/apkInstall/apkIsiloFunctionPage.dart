import 'dart:io';

import 'package:da_ka/mainDir/functions/scanFileFunction/scanPdbFunction.dart';
import 'package:da_ka/mainDir/functions/apkInstall/managePdbFunction.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_extend/share_extend.dart';

class ApkIsiloFunctionPage extends StatefulWidget {
  @override
  _ApkIsiloFunctionPageState createState() => _ApkIsiloFunctionPageState();
}

class _ApkIsiloFunctionPageState extends State<ApkIsiloFunctionPage> {
  var basePath = SpUtil.getString("TEMP_PATH");
  var isiloPackageName = "com.dcco.app.iSilo";
  var kuaichuanPackageName = "com.genonbeta.TrebleShot";
  var isIsiloInstalled = true;
  var isKuaichuanInstalled = true;

  @override
  void initState() {
    super.initState();
    isInstalled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("软件管理")),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: "isilo",
              tiles: [
                SettingsTile(title: "islo 安装", enabled: !isIsiloInstalled, onTap: installIsilo),
                SettingsTile(title: "isilo 启动", enabled: isIsiloInstalled, onTap: invokeIsilo),
                SettingsTile(title: "分享isilo 软件", onTap: shareIsilo),
                SettingsTile(title: "isilo 文件扫描", enabled: isIsiloInstalled, onTap: () => routePush(ScanPdbFunction())),
                SettingsTile(title: "分享/管理已添加文件", enabled: isIsiloInstalled, onTap: () => routePush(ManagePdbFunction())),
              ],
            ),
          ],
        ));
  }

  //测试是否安装软件
  Future<void> isInstalled() async {
    UtilFunction.packageNames().then((value) {
      isIsiloInstalled = value.toString().contains(isiloPackageName);
      setState(() {});
    });
  }

  var apk = "isilo.apk";
  shareIsilo() async {
    var dirName = SpUtil.getString("TEMP_PATH");
    var path = "$dirName/$apk";

    if (!File(path).existsSync()) {
      UtilFunction.copyFile(await rootBundle.load("assets/apk/isilo.apk"), path);
    }
    ShareExtend.share(path, "file");
  }

  // 安装 isilo
  installIsilo() async {
    var dirName = SpUtil.getString("TEMP_PATH");
    UtilFunction.copyFile(await rootBundle.load("assets/apk/$apk"), '$dirName/$apk');
    UtilFunction.installApp({"path": '$dirName/$apk'}).then((value) => isInstalled());
  }

  // 启动 isilo
  invokeIsilo() {
    UtilFunction.invokeApp({"package": isiloPackageName});
  }
}
