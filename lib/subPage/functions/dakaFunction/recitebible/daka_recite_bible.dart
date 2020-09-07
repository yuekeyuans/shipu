import 'package:da_ka/db/bible/bookNameTable.dart';
import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:nav_router/nav_router.dart';
import 'package:settings_ui/settings_ui.dart';

class DakaReciteBiblePage extends StatefulWidget {
  @override
  _DakaReciteBiblePageState createState() => _DakaReciteBiblePageState();
}

class _DakaReciteBiblePageState extends State<DakaReciteBiblePage> {
  getVerseOfDay() async {
    new Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              begin: 1,
              end: 30,
              initValue: ReciteBibleEntity.fromSp().verseOfDay)
        ]),
        hideHeader: true,
        confirmText: "确定",
        cancelText: "取消",
        title: new Text("选择背经节数"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            ReciteBibleTable().deleteToday();
            var entity = ReciteBibleEntity.fromSp();
            entity.verseOfDay = picker.getSelectedValues().first;
            entity.toSp();
          });
        }).showDialog(context);
  }

  getStrategy() async {
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: delay_bible_strategy),
        hideHeader: true,
        confirmText: "确定",
        cancelText: "取消",
        title: new Text("未完成策略"),
        onConfirm: (Picker picker, List value) {
          ReciteBibleTable().deleteToday();
          var entity = ReciteBibleEntity.fromSp();
          entity.delayMode = picker.getSelectedValues().first;
          entity.toSp();
          setState(() {});
        }).showDialog(context);
  }

  getCurrentBook() async {
    var books = await BookNameTable().queryBookNames();
    new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: books),
        hideHeader: true,
        confirmText: "确定",
        cancelText: "取消",
        title: new Text("选择圣经卷"),
        onConfirm: (Picker picker, List value) {
          var entity = ReciteBibleEntity.fromSp();
          if (entity.currentBook != picker.getSelectedValues().first) {
            entity.startDate = DateTime.now();
          }
          ReciteBibleTable().deleteToday();
          entity.currentBook = picker.getSelectedValues().first;
          entity.toSp();
          setState(() {});
        }).showDialog(context);
  }

  getFontSize() {
    new Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              begin: 10,
              end: 40,
              initValue: ReciteBibleEntity.fromSp().fontSize)
        ]),
        hideHeader: true,
        confirmText: "确定",
        cancelText: "取消",
        title: new Text("选择字体大小"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            var entity = ReciteBibleEntity.fromSp();
            entity.fontSize = picker.getSelectedValues().first;
            entity.toSp();
          });
        }).showDialog(context);
  }

  //开启和关闭背经功能
  openReciteMode(bool value) async {
    if (value == true) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text("提示"),
                content: Text("开启背经功能,选择背经的内容"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("确定"))
                ]);
          });
      setState(() {
        var entity = ReciteBibleEntity.fromSp();
        entity.isOn = value;
        entity.toSp();
      });
    } else {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text("提示"),
                content: Text("坚持来之不易,是否继续坚持?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("放弃"),
                    onPressed: () {
                      setState(() {
                        var entity = ReciteBibleEntity.fromSp();
                        entity.isOn = value;
                        entity.toSp();
                        ReciteBibleTable().deleteToday();
                      });
                      pop();
                    },
                  ),
                  FlatButton(onPressed: pop, child: Text("继续坚持"))
                ]);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<SettingsSection> getChildren() {
      var lst = <SettingsSection>[
        SettingsSection(
          title: "开启功能",
          tiles: [
            SettingsTile.switchTile(
              title: "开启背经功能",
              onToggle: openReciteMode,
              switchValue: ReciteBibleEntity.fromSp().isOn,
            )
          ],
        )
      ];
      if (ReciteBibleEntity.fromSp().isOn) {
        lst.add(SettingsSection(title: "设置", tiles: [
          SettingsTile(
              title: "篇目",
              subtitle: ReciteBibleEntity.fromSp().currentBook,
              onTap: getCurrentBook),
          SettingsTile(
              title: "每天背经节数目",
              subtitle: ReciteBibleEntity.fromSp().verseOfDay.toString(),
              onTap: getVerseOfDay),
          SettingsTile(
              title: "没有完成策略",
              subtitle: ReciteBibleEntity.fromSp().delayMode,
              onTap: getStrategy),
          SettingsTile(
              title: "字体大小",
              subtitle: ReciteBibleEntity.fromSp().fontSize.toString(),
              onTap: getFontSize)
        ]));
      }
      return lst;
    }

    return Scaffold(
        appBar: AppBar(title: Text("背经功能")),
        body: SettingsList(
          sections: getChildren(),
        ));
  }
}
