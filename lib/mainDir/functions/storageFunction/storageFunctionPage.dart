import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';

class StorageFunctionPage extends StatefulWidget {
  @override
  _StorageFunctionPageState createState() => _StorageFunctionPageState();
}

class _StorageFunctionPageState extends State<StorageFunctionPage> {
  static const int MEGABYTE = 1024 * 1024;
  static const List<String> extras = ["clock_in.db", "bible.db", "lifestudy.db"];
  MethodChannel channel;
  String freeSize = "0M";
  int totalUseSize = 0;
  int fileSize = 0;
  int audioSize = 0;
  int logFile = 0;

  @override
  void initState() {
    channel = MethodChannel("com.example.clock_in/clean");
    super.initState();
    updateFileSize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("存储管理")),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: '存储信息',
              tiles: [
                SettingsTile(enabled: false, title: "程序使用存储", subtitle: "${totalUseSize ~/ MEGABYTE} MB"),
                SettingsTile(enabled: false, title: "剩余存储", subtitle: freeSize),
              ],
            ),
            SettingsSection(
              title: "程序存储清理",
              tiles: [
                SettingsTile(enabled: true, title: "可清理文件", subtitle: "${fileSize ~/ MEGABYTE} MB", onTap: cleanStorage),
                // SettingsTile(enabled: false, title: "音频清理", subtitle: "${audioSize ~/ MEGABYTE} MB"),
                // SettingsTile(enabled: false, title: "临时文件清理", subtitle: "${audioSize ~/ MEGABYTE} MB 临时文件, 可放心清理")
              ],
            )
          ],
        ));
  }

  Future<void> updateFileSize() async {
    fileSize = getTotalSizeOfFilesInDir(Directory(SpUtil.getString("MAIN_PATH")), recurse: true, extraFiles: true);
    totalUseSize = getTotalSizeOfFilesInDir(Directory(SpUtil.getString("MAIN_PATH")), recurse: true);
    await channel.invokeMethod("avaliableSize").then((value) {
      setState(() => freeSize = value.toString());
    });
    setState(() {});
  }

  void countStorage() {
    Directory mainDir = Directory(SpUtil.getString("MAIN_PATH"));
    for (var a in mainDir.listSync()) {
      print(a.path);
    }
  }

  int getTotalSizeOfFilesInDir(final FileSystemEntity file, {bool recurse = false, bool extraFiles = false}) {
    int totalSize = 0;
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      children.forEach((element) {
        totalSize += getTotalSizeOfFilesInDir(element, recurse: recurse, extraFiles: extraFiles);
      });
      return totalSize;
    } else if (file is File) {
      totalSize = extraFiles && extras.contains(file.path.split("/").last) ? 0 : file.lengthSync();
    }
    return totalSize;
  }

  void cleanStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          FlatButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
          FlatButton(
            onPressed: () {
              deleteFiles(Directory(SpUtil.getString("MAIN_PATH")), recurse: true);
              Navigator.pop(context);
            },
            child: Text("确定"),
          )
        ],
        title: Text("询问"),
        content: Text("确定删除所有文件么?\n当文件删除后，程序中所有引用的文件将不可用"),
      ),
    ).then((value) => updateFileSize());
  }

  Future<void> deleteFiles(final FileSystemEntity file, {bool recurse = false, List<String> extras = extras}) async {
    bool isInExtra(String path) {
      return extras.contains(path.split("/").last);
    }

    if (file is File && !isInExtra(file.path)) {
      file.delete();
      return;
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      if (children != null) {
        for (final child in children) {
          if (recurse) {
            await deleteFiles(child);
          } else {
            if (child is File && !isInExtra(child.path)) {
              await child.delete();
            }
          }
        }
      }
    }
  }
}
