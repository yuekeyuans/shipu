import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_extend/share_extend.dart';

class BackUpAppPage extends StatefulWidget {
  @override
  _BackUpAppPageState createState() => _BackUpAppPageState();
}

class _BackUpAppPageState extends State<BackUpAppPage> {
  MethodChannel channel;
  var basePath = SpUtil.getString("TEMP_PATH");

  @override
  void initState() {
    super.initState();
    channel = MethodChannel("com.example.clock_in/copyApp");
  }

  @override
  Widget build(BuildContext context) {
    var isBackUp = File(basePath + "/$appName").existsSync();

    return Scaffold(
      appBar: AppBar(title: Text("备份软件")),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: "备份软件",
                enabled: !isBackUp,
                trailing: isBackUp ? Icon(Icons.check) : null,
                onTap: () {
                  channel.invokeMethod(
                    "backupApk",
                    {
                      "packageName": packageName,
                      "destPath": SpUtil.getString("TEMP_PATH")
                    },
                  ).then((value) => setState(() {}));
                },
              ),
              SettingsTile(
                title: "发送软件",
                enabled: isBackUp,
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                            height: 140,
                            child: ListView(
                              children: <Widget>[
                                ListTile(
                                  title: Text("系统发送栏"),
                                  onTap: () {
                                    shareIt(basePath + "/" + appName);
                                  },
                                ),
                                Divider(),
                                ListTile(
                                  title: Text("手机热点发送"),
                                  enabled: false,
                                )
                              ],
                            ));
                      });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void shareIt(String path) {
    var file = File(path);
    if (file.existsSync()) {
      ShareExtend.share(path, "file");
    }
  }
}
