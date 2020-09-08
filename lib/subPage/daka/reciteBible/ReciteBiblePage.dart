import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bible/bibleTable.dart';
import 'package:da_ka/db/bible/bookNameTable.dart';
import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:nav_router/nav_router.dart';
import 'package:da_ka/subPage/daka/reciteBible/ReciteBibleTimelinePage.dart';

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
    var record = await ReciteBibleTable().queryByDay(date);
    bibles = await BibleTable().queryByIds(record.ids);
    var bookName = ReciteBibleEntity.fromSp().currentBook;
    shortName = await BookNameTable().queryShortName(bookName);
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
              "背经 - ${DateUtil.formatDate(date, format: DateFormats.zh_mo_d)}"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                    icon: Icon(Icons.menu), onPressed: showBottomSheet))
          ]),
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
                  child: Text("$shortName ${record.chapter}-${record.section}",
                      style: textStyle)),
              Expanded(
                  child: Text(record.content,
                      softWrap: true, maxLines: 10, style: textStyle)),
            ],
          ),
          SizedBox(height: 15),
          Divider(height: 2.0)
        ]));
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 40,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.check), onPressed: checkIn),
                    IconButton(
                      icon: Icon(Icons.music_note),
                      onPressed: () {},
                    ),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.date_range),
                              onPressed: () =>
                                  routePush(ReciteBibleTimelinePage())),
                          IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: prevPage),
                          IconButton(
                              icon: Icon(Icons.pause_circle_outline),
                              onPressed: currPage),
                          IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: nextPage)
                        ])
                  ]));
        });
  }

  listToMusic() {
    
  }

//当天
  currPage() async {
    var temDate = DateTime.now();
    if (!await ReciteBibleTable().existDateRecord(temDate)) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
                content: Text(
                    """${DateUtil.formatDate(temDate, format: DateFormats.y_mo_d)}\n还没有呢开始背经
                  """));
          });
    } else {
      setState(() {
        date = temDate;
        updateData();
      });
    }
  }

//下一天
  nextPage() async {
    var temDate = date.add(Duration(days: 1));
    if (!await ReciteBibleTable().existDateRecord(temDate)) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
                content: Text(
                    """${DateUtil.formatDate(temDate, format: DateFormats.y_mo_d)}\n还没有呢开始背经
                  """));
          });
    } else {
      setState(() {
        date = temDate;
        updateData();
      });
    }
  }

  //上一页
  prevPage() async {
    var temDate = date.add(Duration(days: -1));
    if (!await ReciteBibleTable().existDateRecord(temDate)) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
                content: Text(
                    """${DateUtil.formatDate(temDate, format: DateFormats.y_mo_d)}\n还没有呢开始背经
                    """));
          });
    } else {
      setState(() {
        date = temDate;
        updateData();
      });
    }
  }

  //打卡功能
  Future<void> checkIn() async {
    var entity = await ReciteBibleTable().queryByDay(date);
    if (entity.isComplete) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Text("提示"),
                  content: Text("已经背诵完成，打卡，无需重复打卡"),
                  actions: <Widget>[
                    FlatButton(onPressed: pop, child: Text("好的"))
                  ]));
    } else {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("背诵打卡"),
              content: Text("是否完成背诵任务?\n未完成，不打卡"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () async {
                      entity.isComplete = true;
                      entity.update();
                      setState(() {});
                      pop();
                    },
                    child: Text("完成了")),
                FlatButton(child: Text("没完成"), onPressed: pop)
              ],
            );
          });
    }
  }
}
