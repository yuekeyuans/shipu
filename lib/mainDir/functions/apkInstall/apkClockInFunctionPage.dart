import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_extend/share_extend.dart';

class ApkClockInFunctionPage extends StatefulWidget {
  @override
  _ApkClockInFunctionPageState createState() => _ApkClockInFunctionPageState();
}

class _ApkClockInFunctionPageState extends State<ApkClockInFunctionPage> {
  // MethodChannel copyAppChannel;
  // MethodChannel installApkChannel;
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
              title: "clock_in",
              tiles: [
                SettingsTile(title: "软件备份", onTap: copyClockInFromPhone),
                SettingsTile(title: "发送软件", onTap: shareClockIn),
              ],
            )
          ],
        ));
  }

  //copy clock_in
  void copyClockInFromPhone() {
    UtilFunction.backUpApk({"packageName": packageName, "destPath": SpUtil.getString("TEMP_PATH")}).then((value) {});
  }

  // send clock_in
  Future<void> shareClockIn() async {
    var path = basePath + "/" + appName;
    var file = File(path);
    if (!file.existsSync()) {
      await UtilFunction.backUpApk({"packageName": packageName, "destPath": SpUtil.getString("TEMP_PATH")});
    }
    ShareExtend.share(path, "file");
  }

  //测试是否安装软件
  Future<void> isInstalled() async {
    await UtilFunction.packageNames().then((value) {
      isKuaichuanInstalled = value.toString().contains(kuaichuanPackageName);
      isIsiloInstalled = value.toString().contains(isiloPackageName);
      setState(() {});
    });
  }
}
