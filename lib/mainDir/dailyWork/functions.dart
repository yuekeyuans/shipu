import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:da_ka/views/daka/bibleOneYearNewTestment/ynybXyPage.dart';
import 'package:da_ka/views/daka/bibleOneYearOldTestment/ynybJyPage.dart';
import 'package:da_ka/views/daka/reciteBible/ReciteBiblePage.dart';
import 'package:da_ka/views/smdj/smdjPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nav_router/nav_router.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    updatePage();
  }

  updatePage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(child: AppBar(title: Text("日常")), preferredSize: Size.fromHeight(APPBAR_HEIGHT)),
      body: ListView(
        children: getChildren(),
      ),
    );
  }

  List<Widget> getChildren() {
    var widgets = <Widget>[];

    widgets.addAll(getBj());
    widgets.addAll(getXy());
    widgets.addAll(getJy());
    widgets.addAll(getSmdj());

    return widgets;
  }

  //返回背经
  List<Widget> getBj() {
    var lst = <Widget>[];
    if (ReciteBibleEntity.fromSp().isOn) {
      lst.add(wrapListTile(
        ListTile(
          title: Text("背经"),
          onTap: () => routePush(ReciteBiblePage()).then((value) => updatePage()),
        ),
      ));
      lst.add(Divider(height: 1.0));
    }
    return lst;
  }

  //返回新约
  List<Widget> getXy() {
    var lst = <Widget>[];
    lst.add(wrapListTile(
      ListTile(
        title: Text("一年一遍-新约"),
        onTap: () => routePush(YnybXyPage()).then((value) => updatePage()),
      ),
    ));
    lst.add(Divider(height: 1.0));
    return lst;
  }

  //返回旧约
  List<Widget> getJy() {
    var lst = <Widget>[];
    lst.add(wrapListTile(
      ListTile(
        title: Text("一年一遍-旧约"),
        onTap: () => routePush(YnybJyPage()).then((value) => updatePage()),
      ),
    ));

    lst.add(Divider(height: 1.0));
    return lst;
  }

  //返回生命读经
  List<Widget> getSmdj() {
    var lst = <Widget>[];
    lst.add(wrapListTile(
      ListTile(
        title: Text("每日生命读经"),
        onTap: () => routePush(SmdjPage()).then((value) => updatePage()),
      ),
    ));

    lst.add(Divider(height: 1.0));
    return lst;
  }

  //包装器
  // ignore: avoid_types_as_parameter_names
  Widget wrapListTile(Widget widget, {bool isRead = false, Function onReaded}) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(decoration: BoxDecoration(color: isRead ? Colors.black12 : null), child: widget),
      secondaryActions: <Widget>[
        IconSlideAction(caption: isRead ? '取消打卡' : '打卡', color: Colors.blue, icon: isRead ? Icons.blur_off : Icons.blur_on, onTap: () => onReaded()),
      ],
    );
  }
}
