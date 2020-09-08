import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/db/mainDb/ynybJyTable.dart';
import 'package:da_ka/db/mainDb/ynybXyTable.dart';
import 'package:da_ka/subPage/daka/reciteBible/ReciteBiblePage.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nav_router/nav_router.dart';
import "package:da_ka/subPage/daka/bibleOneYearNewTestment/ynybXyPage.dart";
import "package:da_ka/subPage/daka/bibleOneYearOldTestment/ynybJyPage.dart";
import 'package:da_ka/subPage/daka/smdj/smdjPage.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  DateTime date = DateTime.now();
  bool hasReadXy = false;
  bool hasReadJy = false;
  bool hasReadSmdj = false;
  bool hasBj = false;

  @override
  void initState() {
    super.initState();
    updatePage();
  }

  Future<void> updatePage() async {
    hasReadXy = await YnybXyTable().queryIsComplete(date);
    hasReadJy = await YnybJyTable().queryIsComplete(date);
    hasReadSmdj = false; //TODO:
    hasBj = await ReciteBibleTable().queryIsComplete(date);
    setState(() {});
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
            onTap: () =>
                routePush(ReciteBiblePage()).then((value) => updatePage()),
            trailing: hasBj ? Icon(Icons.check) : null,
          ),
          isRead: hasBj, onReaded: () async {
        await ReciteBibleTable().toggleIsComplete(date, hasBj);
        updatePage();
      }));
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
          trailing: hasReadXy ? Icon(Icons.check) : null,
        ),
        isRead: hasReadXy, onReaded: () async {
      await YnybXyTable().toggleIsComplete(date, hasReadXy);
      updatePage();
    }));
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
          trailing: hasReadJy ? Icon(Icons.check) : null,
        ),
        isRead: hasReadJy, onReaded: () async {
      await YnybJyTable().toggleIsComplete(date, hasReadJy);
      updatePage();
    }));

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
          trailing: hasReadSmdj ? Icon(Icons.check) : null,
        ),
        isRead: hasReadSmdj));

    lst.add(Divider(height: 1.0));
    return lst;
  }

  //包装器
  Widget wrapListTile(Widget widget, {bool isRead = false, Function onReaded}) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
          decoration: new BoxDecoration(color: isRead ? Colors.black12 : null),
          child: widget),
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: isRead ? '取消打卡' : "打卡",
            color: Colors.blue,
            icon: isRead ? Icons.blur_off : Icons.blur_on,
            onTap: onReaded == null ? () {} : onReaded),
      ],
    );
  }
}
