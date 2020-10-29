import 'dart:io';

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
  var basePath = SpUtil.getString("TEMP_PATH");
  var kuaichuanPackageName = "com.genonbeta.TrebleShot";
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
              title: "快传",
              tiles: [
                SettingsTile(title: "快传安装", enabled: !isKuaichuanInstalled, onTap: installKuaichuan),
                SettingsTile(title: "快传启动", enabled: isKuaichuanInstalled, onTap: invokeKuaichuan),
                SettingsTile(title: "分享快传文件", enabled: isKuaichuanInstalled, onTap: shareKuaichuan),
              ],
            ),
          ],
        ));
  }

  //测试是否安装软件
  Future<void> isInstalled() async {
    await UtilFunction.packageNames().then((value) {
      isKuaichuanInstalled = value.toString().contains(kuaichuanPackageName);
      setState(() {});
    });
  }

  var apk = "fastTransport.apk";
  // 安装 快传
  installKuaichuan() async {
    var dirName = SpUtil.getString("TEMP_PATH");
    UtilFunction.copyFile(await rootBundle.load("assets/apk/$apk"), '$dirName/$apk');
    UtilFunction.installApp({"path": '$dirName/$apk'}).then((value) => isInstalled());
  }

  // 启动 快传
  invokeKuaichuan() {
    UtilFunction.invokeApp({"package": kuaichuanPackageName});
  }

  shareKuaichuan() async {
    var path = "$basePath/$apk";
    var file = File(path);
    if (!file.existsSync()) {
      UtilFunction.copyFile(await rootBundle.load("assets/apk/$apk"), path);
    }
    ShareExtend.share(path, "file");
  }
}
