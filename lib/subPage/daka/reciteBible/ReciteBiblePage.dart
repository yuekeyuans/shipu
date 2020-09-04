import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bibleTable.dart';
import 'package:da_ka/db/recitebibleTable.dart';
import 'package:da_ka/subPage/functions/dakaFunction/daka_recite_bible_entity.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";

class ReciteBiblePage extends StatefulWidget {
  @override
  _ReciteBiblePageState createState() => _ReciteBiblePageState();
}

class _ReciteBiblePageState extends State<ReciteBiblePage> {
  DateTime date = DateTime.now();
  List<BibleTable> bibles = [];
  String bookName = "";

  @override
  void initState() {
    super.initState();
    updateData();
  }

  updateData() async {
    var record = await ReciteBibleTable().queryByDay(DateTime.now());
    bibles = await BibleTable().queryByIds(record);
    print(bibles.toString());
    bookName = ReciteBibleEntity.fromSp().currentBook;
    setState(() {});
  }

  bool get isCurrentDate {
    var curDate = DateTime.now();
    if (curDate.year == curDate.year &&
        curDate.month == date.month &&
        curDate.day == date.day) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getChildren() {
      var lst = <Widget>[];
      bibles.forEach((element) {
        lst.add(createCard(element));
      });
      return lst;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "背经 - ${DateUtil.formatDate(date, format: DateFormats.zh_y_mo_d)}"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child:
                isCurrentDate ? Icon(Icons.date_range) : Icon(Icons.av_timer),
          )
        ],
      ),
      body: ListView(children: getChildren()),
    );
  }

  Widget createCard(BibleTable record) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Text(
            "$bookName ${record.chapter}:${record.section}",
            textAlign: TextAlign.left,
          ),
          Divider(),
          Text(
            record.content,
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 25),
          ),
        ]),
      ),
    );
  }
}
