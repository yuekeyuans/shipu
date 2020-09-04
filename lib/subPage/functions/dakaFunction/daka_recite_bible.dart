import 'package:da_ka/db/bibleTable.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/subPage/functions/dakaFunction/daka_recite_bible_entity.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class DakaReciteBiblePage extends StatefulWidget {
  @override
  _DakaReciteBiblePageState createState() => _DakaReciteBiblePageState();
}

class _DakaReciteBiblePageState extends State<DakaReciteBiblePage> {
  Future<void> getVerseOfDay() async {
    List<Widget> getChildren() {
      var lst = <Widget>[];
      for (int i = 1; i <= 30; i++) {
        lst.add(ListTile(
            title: Text(i.toString() + "节"),
            onTap: () {
              setState(() {
                var entity = ReciteBibleEntity.fromSp();
                entity.verseOfDay = i;
                entity.toSp();
              });
              Navigator.pop(context);
            }));
        lst.add(Divider(height: 1.0));
      }
      return lst;
    }

    await showDialog(
        context: context,
        builder: (context) =>
            SimpleDialog(title: Text("请选择每天背的节数"), children: getChildren()));
  }

  Future<void> getStrategy() async {
    List<Widget> getChildren() {
      var lst = <Widget>[];
      for (var item in delay_bible_strategy) {
        lst.add(ListTile(
            title: Text(item),
            onTap: () {
              setState(() {
                var entity = ReciteBibleEntity.fromSp();
                entity.delayMode = item;
                entity.toSp();
              });
              Navigator.pop(context);
            }));
        lst.add(Divider(height: 1.0));
      }
      return lst;
    }

    await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: Text("请选择未完成的策略"),
              children: getChildren(),
            ));
  }

  Future<void> getCurrentBook() async {
    var books = await BookName().queryBookNames();

    List<Widget> getChildren() {
      var lst = <Widget>[];
      for (var book in books) {
        lst.add(ListTile(
            title: Text(book.name),
            onTap: () {
              setState(() {
                var entity = ReciteBibleEntity.fromSp();
                entity.currentBook = book.name;
                entity.toSp();
              });
              Navigator.pop(context);
            },
            dense: true));
        lst.add(Divider(height: 1.0));
      }
      return lst;
    }

    await showDialog(
        context: context,
        builder: (context) =>
            SimpleDialog(title: Text("请选择圣经卷"), children: getChildren()));
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
              onToggle: (value) async {
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
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("继续坚持"))
                            ]);
                      });
                }
              },
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
              onTap: () async {
                await getCurrentBook();
              }),
          SettingsTile(
              title: "每天背经节数目",
              subtitle: ReciteBibleEntity.fromSp().verseOfDay.toString(),
              onTap: () async {
                await getVerseOfDay();
              }),
          SettingsTile(
              title: "没有完成策略",
              subtitle: ReciteBibleEntity.fromSp().delayMode,
              onTap: () async {
                await getStrategy();
              })
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
