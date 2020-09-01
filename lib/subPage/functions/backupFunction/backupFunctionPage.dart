import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';

class BackUpAppPage extends StatefulWidget {
  @override
  _BackUpAppPageState createState() => _BackUpAppPageState();
}

class _BackUpAppPageState extends State<BackUpAppPage> {
  MethodChannel channel;

  @override
  void initState() {
    super.initState();
    channel = MethodChannel("com.example.clock_in/copyApp");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("备份软件")),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                title: "备份软件",
                onTap: () {
                  channel.invokeMethod(
                    "backupApk",
                    {
                      "packageName": "com.example.clock_in",
                      "destPath": SpUtil.getString("TEMP_PATH")
                    },
                  );
                },
              ),
              SettingsTile(title: "发送软件"),
            ],
          )
        ],
      ),
    );
  }
}
