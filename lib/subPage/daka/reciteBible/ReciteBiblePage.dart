import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bibleTable.dart';
import 'package:da_ka/db/recitebibleTable.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";

class ReciteBiblePage extends StatefulWidget {
  @override
  _ReciteBiblePageState createState() => _ReciteBiblePageState();
}

class _ReciteBiblePageState extends State<ReciteBiblePage> {
  DateTime date = DateTime.now();
  List<BibleTable> bibles = [];
  String shortName;

  var textStyle = TextStyle(
      fontSize: ReciteBibleEntity.fromSp().fontSize.toDouble(),
      fontFamily: "OpenSans");

  @override
  void initState() {
    super.initState();
    updateData();
  }

  updateData() async {
    var record = await ReciteBibleTable().queryByDay(DateTime.now());
    bibles = await BibleTable().queryByIds(record);
    var bookName = ReciteBibleEntity.fromSp().currentBook;
    shortName = await BookName().queryShortName(bookName);
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
            child: isCurrentDate
                ? Icon(Icons.date_range)
                : Icon(Icons.keyboard_return),
          )
        ],
      ),
      body: ListView(children: getChildren()),
    );
  }

  Widget createCard(BibleTable record) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
        child: Column(children: [
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Text(
                  "$shortName ${record.chapter}-${record.section}",
                  style: textStyle,
                ),
              ),
              Expanded(
                  child: Text(
                record.content,
                softWrap: true,
                maxLines: 10,
                style: textStyle,
              )),
            ],
          ),
          SizedBox(height: 15),
          Divider(height: 2.0)
        ]));
  }
}
