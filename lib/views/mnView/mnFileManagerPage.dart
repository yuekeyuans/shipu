import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

/// 管理 晨兴的文件
class MnFileManagerPage extends StatefulWidget {
  @override
  _MnFileManagerPageState createState() => _MnFileManagerPageState();
}

class _MnFileManagerPageState extends State<MnFileManagerPage> {
  List<String> addedFile = [];
  List<String> searchedFile = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("管理晨兴文件")), body: createBody());
  }

  Widget createBody() {
    List<SettingsTile> addedFileTiles = [];
    if (addedFile.isEmpty) {
      addedFileTiles = [SettingsTile(title: '没有已添加文件')];
    } else {
      addedFileTiles = addedFile.map((element) {
        return SettingsTile(title: element);
      }).toList();
    }

    List<SettingsTile> searchedFileTiles = [];
    if (searchedFile.isEmpty) {
      searchedFileTiles = [SettingsTile(title: "没有未添加文件")];
    } else {
      searchedFileTiles = searchedFile
          .map((e) => SettingsTile(
                title: e,
              ))
          .toList();
    }
    return SettingsList(
      sections: [
        SettingsSection(title: null, tiles: [
          SettingsTile(
            title: "点击查找文件",
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
            onTap: () {
              print("开始查找新文件");
            },
          ),
        ]),
        SettingsSection(
          title: "已存在文件",
          tiles: addedFileTiles,
        ),
        SettingsSection(
          title: "未添加的文件",
          tiles: searchedFileTiles,
        ),
      ],
    );
  }
}
