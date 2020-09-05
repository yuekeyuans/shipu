import 'package:da_ka/subPage/daka/reciteBible/ReciteBiblePage.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<String> items = new List<String>();

  @override
  void initState() {
    super.initState();
    items
      ..add("背经")
      ..add("新约")
      ..add("旧约")
      ..add("生命读经")
      ..add("每月一书")
      ..add("每日一歌");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: getChildren(),
      ),
    );
  }

  List<Widget> getChildren() {
    var widget = <Widget>[];
    if (ReciteBibleEntity.fromSp().isOn) {
      widget.add(ListTile(
        title: Text("背经"),
        onTap: () => routePush(ReciteBiblePage()),
        trailing: Icon(Icons.check),
      ));
      widget.add(Divider());
    }
    return widget;
  }
}
