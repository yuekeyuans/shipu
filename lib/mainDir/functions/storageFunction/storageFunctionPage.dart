import 'dart:io';

import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:filesize/filesize.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';

class StorageFunctionPage extends StatefulWidget {
  @override
  _StorageFunctionPageState createState() => _StorageFunctionPageState();
}

class _StorageFunctionPageState extends State<StorageFunctionPage> {
  static const List<String> extras = ["clock_in.db", "bible.db", "lifestudy.db"];
  MethodChannel channel;
  String freeSize = "0M";
  int totalUseSize = 0;
  int allFileSize = 0;
  int cleanableFileSize = 0;
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
                SettingsTile(enabled: false, title: "程序使用存储", subtitle: filesize(totalUseSize)),
                SettingsTile(enabled: false, title: "剩余存储", subtitle: freeSize),
              ],
            ),
            SettingsSection(
              title: "程序存储清理",
              tiles: [
                SettingsTile(title: "临时文件清理", subtitle: filesize(cleanableFileSize), onTap: cleanableStorage),
                SettingsTile(title: "清理全部文件", subtitle: filesize(allFileSize), onTap: cleanAllStorage),
              ],
            )
          ],
        ));
  }

  Future<void> updateFileSize() async {
    allFileSize = getTotalSizeOfFilesInDir(Directory(SpUtil.getString("MAIN_PATH")), recurse: true, extraFiles: true);
    totalUseSize = getTotalSizeOfFilesInDir(Directory(SpUtil.getString("MAIN_PATH")), recurse: true);
    cleanableFileSize = getTotalSizeOfFilesInDir(Directory(SpUtil.getString("MAIN_PATH") + "/temp"));
    await channel.invokeMethod("avaliableSize").then((value) {
      setState(() => freeSize = value.toString());
    });
    setState(() {});
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

  //可以随意清理的文件
  void cleanableStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          FlatButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
          FlatButton(
            onPressed: () async {
              await deleteFiles(Directory(SpUtil.getString("MAIN_PATH") + "/temp"), recurse: true);
              updateFileSize();

              Navigator.pop(context);
            },
            child: Text("确定"),
          )
        ],
        title: Text("询问"),
        content: Text("是否清理?"),
      ),
    );
  }

  void cleanAllStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: <Widget>[
          FlatButton(onPressed: () => Navigator.pop(context), child: Text("取消")),
          FlatButton(
            onPressed: () async {
              await deleteFiles(Directory(SpUtil.getString("MAIN_PATH")), recurse: true);
              updateFileSize();
              ContentFileInfoTable.scanMainDir();
              Navigator.pop(context);
            },
            child: Text("确定"),
          )
        ],
        title: Text("警告", style: TextStyle(color: Colors.red)),
        content: Text("确定删除所有文件么?\n当文件删除后，程序中所有引用的文件将不可用"),
      ),
    );
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
