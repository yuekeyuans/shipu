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

  Future<void> updateFileSize() async {
    fileSize = (await _getTotalSizeOfFilesInDir(
            Directory(SpUtil.getString("MAIN_PATH"))))
        .toInt();

    totalUseSize = (await _getTotalSizeOfFilesInDir(
            Directory(SpUtil.getString("MAIN_PATH")),
            recurse: true))
        .toInt();
    channel.invokeMethod("avaliableSize").then((value) {
      setState(() => freeSize = value);
    });
    setState(() {});
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
                SettingsTile(
                    enabled: false,
                    title: "程序使用存储",
                    subtitle: "${totalUseSize ~/ MEGABYTE} MB"),
                SettingsTile(enabled: false, title: "剩余存储", subtitle: freeSize)
              ],
            ),
            SettingsSection(
              title: "程序存储清理",
              tiles: [
                SettingsTile(
                  enabled: true,
                  title: "文件清理",
                  subtitle: "${fileSize ~/ MEGABYTE} MB",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("取消"),
                          ),
                          FlatButton(
                            onPressed: () {
                              _deleteFiles(
                                  Directory(SpUtil.getString("MAIN_PATH")));
                              Navigator.pop(context);
                            },
                            child: Text("确定"),
                          )
                        ],
                        title: Text("询问"),
                        content: Text("确定删除所有文件么?\n当文件删除后，程序中所有引用的文件将不可用"),
                      ),
                    );
                  },
                ),
                SettingsTile(
                    enabled: false,
                    title: "音频清理",
                    subtitle: "${audioSize ~/ MEGABYTE} MB"),
                SettingsTile(
                  enabled: false,
                  title: "临时文件清理",
                  subtitle: "${audioSize ~/ MEGABYTE} MB 临时文件, 可放心清理",
                )
              ],
            )
          ],
        ));
  }

  void countStorage() {
    Directory mainDir = Directory(SpUtil.getString("MAIN_PATH"));
    for (var a in mainDir.listSync()) {
      print(a.path);
    }
  }

  Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file,
      {bool recurse = false}) async {
    if (file is File) {
      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      double total = 0;
      if (children != null)
        for (final FileSystemEntity child in children) {
          if (recurse) {
            total += await _getTotalSizeOfFilesInDir(child);
          } else {
            if (child is File) {
              total += (await child.length());
            }
          }
        }
      return total;
    }
    return 0;
  }

  static const List<String> extras = ["clock_in.db"];
  Future<void> _deleteFiles(final FileSystemEntity file,
      {bool recurse = false, List<String> extras = extras}) async {
    bool isInExtra(String path) {
      if (extras == null) {
        return false;
      }
      return extras.contains(path.split("/").last);
    }

    if (file is File && !isInExtra(file.path)) {
      file.delete();
      return;
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      if (children != null)
        for (final FileSystemEntity child in children) {
          if (recurse) {
            await _deleteFiles(child);
          } else {
            if (child is File && !isInExtra(child.path)) {
              child.delete();
            }
          }
        }
    }
  }
}
