import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bible/bibleContentTable.dart';
import 'package:da_ka/db/bible/bookNameTable.dart';
import 'package:da_ka/db/mainDb/recitebibleTable.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ReciteBiblePage extends StatefulWidget {
  @override
  _ReciteBiblePageState createState() => _ReciteBiblePageState();
}

class _ReciteBiblePageState extends State<ReciteBiblePage> {
  List<BibleContentTable> bibles = [];
  DateTime date = DateTime.now();
  FlutterTts flutterTts = FlutterTts();
  ReciteBibleTable record = ReciteBibleTable();
  String shortName;
  var textStyle = TextStyle(
      fontSize: ReciteBibleEntity.fromSp().fontSize.toDouble(),
      fontFamily: "OpenSans");

  @override
  void initState() {
    super.initState();
    updateData();
    flutterTts.setLanguage("zh-CN");
  }

  updateData() async {
    record = await ReciteBibleTable().queryByDay(date);
    bibles = await BibleContentTable().queryByIds(record.ids);
    var bookName = ReciteBibleEntity.fromSp().currentBook;
    shortName = await BookNameTable().queryShortName(bookName);
    setState(() {});
  }

  bool get isCurrentDate {
    var curDate = DateTime.now();
    return (curDate.year == curDate.year &&
        curDate.month == date.month &&
        curDate.day == date.day);
  }

  //创建 圣经节
  Widget createCard(BibleContentTable record) {
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
          Divider(height: 1.0)
        ]));
  }

  //显示附加功能
  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 40,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.blur_on), onPressed: checkIn),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.music_note),
                            onPressed: showMusicPlay,
                          ),
                          IconButton(
                              icon: Icon(Icons.date_range),
                              onPressed: showDateInfo),
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

  //听音频
  showMusicPlay() {
    var playState = List.filled(bibles.length, false);
    var continuePlay = true;
    var currentIndex = 0;
    var firstRun = true;
    var content = bibles.first.content;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            //在这里定义函数，可以直接更新页面
            var play = () async {
              playState = List.filled(bibles.length, false);
              if (currentIndex == bibles.length) {
                currentIndex = 0;
                content = bibles[currentIndex].content;
                playState[currentIndex] = true;
                setDialogState(() {});
              } else {
                playState[currentIndex] = true;
                content = bibles[currentIndex].content;
                setDialogState(() {});
                await flutterTts.speak(bibles[currentIndex].content);
                currentIndex++;
              }
            };
            var autoPlay = () async {
              flutterTts.setCompletionHandler(() async {
                if (continuePlay) {
                  await play();
                }
              });
              play();
            };
            //开始第一次循环播放
            if (firstRun) {
              autoPlay();
              firstRun = false;
            }

            return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return Container(
                      constraints: BoxConstraints(minHeight: 250),
                      child: Wrap(children: [
                        Wrap(
                            children: bibles
                                .map<Widget>((e) => FlatButton(
                                    onPressed: () => setDialogState(() {
                                          currentIndex = bibles.indexOf(e);
                                          continuePlay = false;
                                          play();
                                        }),
                                    color: playState[bibles.indexOf(e)]
                                        ? Colors.red
                                        : null,
                                    child: Text(
                                        "$shortName ${e.chapter}-${e.section}")))
                                .toList()),
                        SizedBox(height: 20),
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child:
                                Text(content, style: TextStyle(fontSize: 20)))
                      ]));
                });
          });
        }).then((value) {
      flutterTts.stop();
      flutterTts.setCompletionHandler(null);
    });
  }

  //展示背经情况
  showDateInfo() async {
    var records =
        (await ReciteBibleTable().queryCurrentBookList(date)).reversed.toList();
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Column(
                    children: records.map<TimelineTile>((e) {
                  return TimelineTile(
                      alignment: TimelineAlign.manual,
                      lineX: 0.1,
                      isFirst: records.indexOf(e) == 0,
                      isLast: records.indexOf(e) == records.length - 1,
                      indicatorStyle: IndicatorStyle(
                        width: 20,
                        color: e.isComplete ? Colors.green : Colors.purple,
                      ),
                      topLineStyle: const LineStyle(
                        color: Colors.purple,
                        width: 6,
                      ),
                      rightChild: Container(
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  DateUtil.formatDate(e.date,
                                      format: DateFormats.y_mo_d),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w200)),
                              Text(
                                  (e.isComplete ? "已完成" : "没有完成") +
                                      "${e.ids.length}节圣经背诵",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Divider()
                            ],
                          )));
                }).toList());
              });
        });
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
    showDialog(
        context: context,
        builder: (context) => record.isComplete
            ? AlertDialog(
                title: Text("提示"),
                content: Text("已经背诵完成，打卡，无需重复打卡"),
                actions: <Widget>[
                    FlatButton(onPressed: pop, child: Text("好的"))
                  ])
            : AlertDialog(
                title: Text("背诵打卡"),
                content: Text("是否完成背诵任务?\n未完成，不打卡"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () async {
                        record.isComplete = true;
                        record.update();
                        setState(() {});
                        pop();
                      },
                      child: Text("完成了")),
                  FlatButton(child: Text("没完成"), onPressed: pop)
                ],
              )).then((value) => setState(() {}));
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
}
