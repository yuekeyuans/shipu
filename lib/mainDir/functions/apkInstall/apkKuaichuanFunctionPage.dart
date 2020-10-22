import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_extend/share_extend.dart';

class ApkKuaichuanFunctionPage extends StatefulWidget {
  @override
  _ApkKuaichuanFunctionPageState createState() => _ApkKuaichuanFunctionPageState();
}

class _ApkKuaichuanFunctionPageState extends State<ApkKuaichuanFunctionPage> {
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
            // SettingsSection(
            // title: "isilo",
            // tiles: [
            // SettingsTile(title: "islo 安装", enabled: !isIsiloInstalled, onTap: installIsilo),
            // SettingsTile(title: "isilo 启动", enabled: isIsiloInstalled, onTap: invokeIsilo),
            // SettingsTile(title: "isilo 文件扫描", enabled: isIsiloInstalled, onTap: () => routePush(ScanPdbFunction())),
            // ],
            // ),
            SettingsSection(
              title: "快传",
              tiles: [
                SettingsTile(title: "快传安装", enabled: !isKuaichuanInstalled, onTap: installKuaichuan),
                SettingsTile(title: "快传启动", enabled: isKuaichuanInstalled, onTap: invokeKuaichuan),
                SettingsTile(title: "快传文件预备", enabled: isKuaichuanInstalled),
              ],
            ),
            // SettingsSection(
            // title: "clock_in",
            // tiles: [
            // SettingsTile(title: "软件备份", enabled: !isClockInBackUp, onTap: copyClockInFromPhone),
            // SettingsTile(title: "发送软件", enabled: isClockInBackUp, onTap: () => shareClockIn(basePath + "/" + appName)),
            // ],
            // )
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
