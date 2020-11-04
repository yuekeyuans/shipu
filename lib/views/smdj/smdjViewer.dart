import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyTable.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/DakaSettings.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/dakaSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_extend/share_extend.dart';

class SmdjViewer extends StatefulWidget {
  final int book;
  final int chapter;
  SmdjViewer(this.book, this.chapter);

  @override
  _SmdjViewerState createState() => _SmdjViewerState();
}

class _SmdjViewerState extends State<SmdjViewer> {
  double baseScaleFactor = 1.0;
  AutoScrollController controller;
  FlutterTts flutterTts = FlutterTts();
  List<LifeStudyRecord> records = [];

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical, suggestedRowHeight: 200);
    update();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> update() async {
    //更新声音
    var e = DakaSettingsEntity.fromSp();
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);
    records = await LifeStudyTable().queryChapter(bookIndex: widget.book, chapter: widget.chapter);
    baseScaleFactor = DakaSettingsEntity.fromSp().baseFont;
    setState(() {});
  }

  Widget wrapScrollWidget(int index) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: wrapOperationWidget(index),
      highlightColor: Colors.black.withOpacity(0.2),
    );
  }

  Widget wrapOperationWidget(int index) {
    return Container(
        color: (records[index].mark == "" || records[index].mark == null) ? Colors.transparent : UtilFunction.stringToColor(records[index].mark),
        child: Column(children: <Widget>[
          SizedBox(height: 5.0),
          GestureDetector(child: createWidget(index), onLongPress: () => longPressParagraph(index)),
          SizedBox(height: 5.0),
        ]));
  }

  //长按效果
  void longPressParagraph(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: <Widget>[
            ListTile(
                dense: true,
                title: Text("复制"),
                onTap: () {
                  pop();
                  Clipboard.setData(ClipboardData(text: records[index].content));
                  showToast("复制成功");
                }),
            ListTile(
              dense: true,
              title: Text("分享"),
              onTap: () {
                pop();
                ShareExtend.share(records[index].content, "text");
              },
            ),
            ListTile(
                dense: true,
                title: records[index].mark == "" ? Text("标记") : Text("取消标记"),
                onTap: () {
                  pop();
                  markIt(records[index]);
                }),
            ListTile(
                dense: true,
                title: Text("朗读"),
                onTap: () {
                  pop();
                  play(setState);
                })
          ]);
        });
  }

  //底部导航栏
  Future<void> showBottomSheetDialog() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return Container(
                height: 40,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  //打卡
                  IconButton(icon: Icon(Icons.list), onPressed: showOutline),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 播放音频
                      playState == 0
                          ? IconButton(
                              icon: Icon(Icons.stop),
                              onPressed: () => play(setDialogState),
                            )
                          : IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () => pause(setDialogState),
                            ),
                      //设置
                      IconButton(icon: Icon(Icons.settings), onPressed: () => routePush(DakaSettings()).then((value) => update())),
                    ],
                  )
                ]));
          });
        });
  }

//////////////////////////
  ///功能处理
//////////////////////////
  ///
  ///
  List<Widget> get outline {
    var widgets = <Widget>[];
    records.forEach((element) {
      if (UtilFunction.isNumeric(element.flag)) {
        var index = records.indexOf(element);
        widgets.add(InkWell(
            child: createWidget(index),
            onTap: () {
              controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
              pop();
            }));
      }
    });
    return widgets;
  }

// 纲目
  void showOutline() {
    pop();
    showModalBottomSheet(
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Column(
            children: outline,
          ));
        },
        context: context);
  }

  //标记

  Future<void> markIt(LifeStudyRecord record) async {
    var info = record.mark;
    bool isMarked = record.mark == "";
    print(record.mark);
    if (isMarked) {
      openColorDialog(
          "Main Color picker",
          MaterialColorPicker(
              allowShades: false,
              onMainColorChange: (color) => setState(
                    () => info = UtilFunction.colorToString(color),
                  )), submit: () async {
        print(info);
        await record.setMarked(info);
        setState(() {});
      });
    } else {
      await record.setMarked("");
      setState(() {});
    }
  }

  //颜色对话框
  void openColorDialog(String title, Widget content, {Function submit}) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                submit();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//////////////////////////
  ///音频
//////////////////////////
  int playState = 0;
  int currentIndex = 0;
  bool hasInitHandler = false;
  void play(StateSetter setDialogState) {
    if (!hasInitHandler) {
      hasInitHandler = true;
      flutterTts.setCompletionHandler(() {
        if (records.length <= currentIndex) {
          pause(setDialogState);
        } else {
          play(setDialogState);
        }
      });
    }

    if (records.length > currentIndex) {
      flutterTts.speak(records[currentIndex].content);
      controller.scrollToIndex(currentIndex, preferPosition: AutoScrollPosition.begin);
      playState = 1;
      currentIndex = currentIndex + 1;
      setDialogState(() {});
    } else {
      currentIndex = 0;
      playState = 0;
      setDialogState(() {});
      flutterTts.stop();
    }
  }

  void pause(StateSetter setDialogState) {
    flutterTts.stop();
    hasInitHandler = false;
    playState = 0;
    currentIndex = currentIndex == 0 ? 0 : currentIndex - 1;
    setDialogState(() {});
  }

//////////////////////////
  /// 文本处理
//////////////////////////
  /// 这是一个大类 TODO: 需要在之后被重新拆分,但是现在由于代码比较混乱，就先不动
  Widget createWidget(int index) {
    //缩进文本
    String indent(String content, double size) {
      return "                                                                                                    ".substring(0, (size * 4).toInt()) + content;
    }

//基本内容
    Widget createContent(int index) {
      return ListTile(
        title: Text(
          indent(records[index].content, 2),
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//总标题
    Widget createTitle(int index) {
      return ListTile(
          title: Text(
        records[index].content ?? "",
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        textScaleFactor: baseScaleFactor + 0.2,
      ));
    }

//TODO:读经
    Widget createReadingBible(int index) {
      return ListTile(
        title: Text(
          records[index].content,
          style: TextStyle(color: Colors.blue),
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//TODO:图表
    Widget createMap(int index) {
      return Icon(Icons.map);
    }

//TODO: h1
    Widget createH1(int index) {
      return ListTile(
        title: Text(
          records[index].content,
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//TODO: h2
    Widget createH2(int index) {
      return ListTile(
        title: Text(
          records[index].content,
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//TODO: h3
    Widget createH3(int index) {
      return ListTile(
        title: Text(
          records[index].content,
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//1
    Widget createHL1(int index) {
      return Container(
          // decoration: BoxDecoration(color: Colors.grey[200]),
          child: ListTile(
        title: Text(
          records[index].content,
          style: TextStyle(fontWeight: FontWeight.bold),
          textScaleFactor: baseScaleFactor + 0.4,
        ),
      ));
    }

//2
    Widget createHL2(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 1),
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: baseScaleFactor + 0.1,
            ),
          ));
    }

//3
    Widget createHL3(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 2),
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

//4
    Widget createHL4(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 2.5),
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

//5
    Widget createHL5(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 3),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

//6
    Widget createHL6(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 3.5),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor,
            ),
          ));
    }

//7
    Widget createHL7(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 4),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor - 0.05,
            ),
          ));
    }

//8
    Widget createHL8(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 4.5),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor - 0.1,
            ),
          ));
    }

//9
    Widget createHL9(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 5),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor - 0.1,
            ),
          ));
    }

//10
    Widget createHL10(int index) {
      return Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 5.5),
              style: TextStyle(fontWeight: FontWeight.w200),
              textScaleFactor: baseScaleFactor - 0.15,
            ),
          ));
    }

    switch (records[index].flag) {
      case "c":
        return createContent(index);
      case 't':
        return createReadingBible(index);
      case "p":
        return createMap(index);
      case "h1":
        return createH1(index);
      case "h2":
        return createH2(index);
      case "h3":
        return createH3(index);
      case "0":
        return createTitle(index);
      case '1':
        return createHL1(index);
      case '2':
        return createHL2(index);
      case '3':
        return createHL3(index);
      case '4':
        return createHL4(index);
      case '5':
        return createHL5(index);
      case '6':
        return createHL6(index);
      case '7':
        return createHL7(index);
      case '8':
        return createHL8(index);
      case '9':
        return createHL9(index);
      case '10':
        return createHL10(index);
    }
    return Text("default");
  }

  @override
  Widget build(BuildContext context) {
    String name = records.isEmpty ? "" : records[0].content;
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(APPBAR_HEIGHT), child: AppBar(title: Text(name), actions: <Widget>[Padding(padding: EdgeInsets.only(right: 10), child: IconButton(icon: Icon(Icons.menu), onPressed: showBottomSheetDialog))])),
        body: Scrollbar(
          child: Container(
            color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
            child: ListView(
              shrinkWrap: true,
              controller: controller,
              scrollDirection: Axis.vertical,
              children: records.map((e) => wrapScrollWidget(records.indexOf(e))).toList(),
            ),
          ),
        ));
  }
}
