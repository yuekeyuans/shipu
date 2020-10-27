import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_extend/share_extend.dart';

class ApkClockInFunctionPage extends StatefulWidget {
  @override
  _ApkClockInFunctionPageState createState() => _ApkClockInFunctionPageState();
}

class _ApkClockInFunctionPageState extends State<ApkClockInFunctionPage> {
  MethodChannel copyAppChannel;
  MethodChannel installApkChannel;
  var basePath = SpUtil.getString("TEMP_PATH");
  var isiloPackageName = "com.dcco.app.iSilo";
  var kuaichuanPackageName = "com.genonbeta.TrebleShot";
  var isIsiloInstalled = true;
  var isKuaichuanInstalled = true;

  @override
  void initState() {
    super.initState();
    copyAppChannel = MethodChannel("com.example.clock_in/copyApp");
    installApkChannel = const MethodChannel("com.example.clock_in/app");
    isInstalled();
  }

  @override
  Widget build(BuildContext context) {
    var isClockInBackUp = File(basePath + "/$appName").existsSync();

    return Scaffold(
        appBar: AppBar(title: Text("软件管理")),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: "clock_in",
              tiles: [
                SettingsTile(title: "软件备份", enabled: !isClockInBackUp, onTap: copyClockInFromPhone),
                SettingsTile(title: "发送软件", enabled: isClockInBackUp, onTap: () => shareClockIn(basePath + "/" + appName)),
              ],
            )
          ],
        ));
  }

  //copy clock_in
  void copyClockInFromPhone() {
    copyAppChannel.invokeMethod(
      "backupApk",
      {"packageName": packageName, "destPath": SpUtil.getString("TEMP_PATH")},
    ).then((value) => setState(() {}));
  }

  // send clock_in
  void shareClockIn(String path) {
    var file = File(path);
    if (file.existsSync()) {
      ShareExtend.share(path, "file");
    }
  }

  //测试是否安装软件
  Future<void> isInstalled() async {
    await installApkChannel.invokeMethod("isInstalled").then((value) {
      isKuaichuanInstalled = value.toString().contains(kuaichuanPackageName);
      isIsiloInstalled = value.toString().contains(isiloPackageName);
      setState(() {});
    });
  }

  // 安装 isilo
  installIsilo() async {
    var dirName = SpUtil.getString("TEMP_PATH");
    UtilFunction.copyFile(await rootBundle.load("assets/apk/isilo.apk"), '$dirName/isilo.apk');
    installApkChannel.invokeMethod("installIsilo", {"path": '$dirName/isilo.apk'}).then((value) => isInstalled());
  }

  // 启动 isilo
  invokeIsilo() {
    installApkChannel.invokeMethod("startApp", {"package": isiloPackageName});
  }

  // 安装 快传
  installKuaichuan() async {
    var apk = "fastTransport.apk";
    var dirName = SpUtil.getString("TEMP_PATH");
    UtilFunction.copyFile(await rootBundle.load("assets/apk/$apk"), '$dirName/$apk');
    installApkChannel.invokeMethod("installIsilo", {"path": '$dirName/$apk'}).then((value) => isInstalled());
  }

// 启动 快传
  invokeKuaichuan() {
    installApkChannel.invokeMethod("startApp", {"package": kuaichuanPackageName});
  }
}
