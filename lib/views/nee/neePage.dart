import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/readingSettingsFunction/ReadingSettings.dart';
import 'package:da_ka/mainDir/functions/readingSettingsFunction/readingSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flutter/material.dart';
import 'package:da_ka/db/neeDb/neeContentTable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/helpers/show_swatch_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_extend/share_extend.dart';

class NeePage extends StatefulWidget {
  final int bookInex;
  final int chapter;
  NeePage(this.bookInex, this.chapter);
  @override
  _NeePageState createState() => _NeePageState();
}

class _NeePageState extends State<NeePage> {
  List<NeeContentTable> mixedList = [];
  AutoScrollController controller;
  String title = "倪文集";
  double baseScaleFactor = 1.0;
  FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
      suggestedRowHeight: 200,
    );
    updateSetting();
    updateData();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> updateSetting() async {
    //更新声音
    flutterTts = FlutterTts();
    var e = ReadingSettingsEntity.fromSp();
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);
    baseScaleFactor = ReadingSettingsEntity.fromSp().baseFont;
    setState(() {});
  }

  Future<void> updateData() async {
    mixedList = await NeeContentTable().queryChapter(bookIndex: widget.bookInex, chapter: widget.chapter);
    title = mixedList.first.content;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(APPBAR_HEIGHT), child: AppBar(title: Text(title), actions: <Widget>[Padding(padding: EdgeInsets.only(right: 10), child: IconButton(icon: Icon(Icons.menu), onPressed: showBottomSheetDialog))])),
        body: Scrollbar(
          child: Container(
            color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
            child: ListView(
              shrinkWrap: true,
              controller: controller,
              scrollDirection: Axis.vertical,
              children: mixedList.map<AutoScrollTag>((e) => wrapScrollWidget(mixedList.indexOf(e))).toList(),
            ),
          ),
        ));
  }

////////////////////////////
  ///长按效果
//////////////////////////
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
                  Clipboard.setData(ClipboardData(text: mixedList[index].content));
                  showToast("复制成功");
                }),
            ListTile(
              dense: true,
              title: Text("分享"),
              onTap: () {
                pop();
                ShareExtend.share(mixedList[index].content, "text");
              },
            ),
            ListTile(
                dense: true,
                title: mixedList[index].mark == "" ? Text("标记") : Text("取消标记"),
                onTap: () {
                  pop();
                  markIt(mixedList[index]);
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

//////////////////////////
  ///功能处理
//////////////////////////
  ///
  ///
  List<Widget> get outline {
    var widgets = <Widget>[];
    mixedList.forEach((element) {
      if (UtilFunction.isNumeric(element.flag)) {
        var index = mixedList.indexOf(element);
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

  Future<void> markIt(NeeContentTable record) async {
    var info = record.mark;
    bool isMarked = record.mark == "";
    print(record.mark);
    if (isMarked) {
      Color swatch = Colors.blue;
      //颜色改变
      showMaterialSwatchPicker(
        title: "选取背景色",
        context: context,
        selectedColor: swatch,
        onChanged: (color) => setState(() => info = UtilFunction.colorToString(color)),
        onConfirmed: () async {
          await record.setMarked(info);
          setState(() {});
        },
      );
    } else {
      await record.setMarked("");
      setState(() {});
    }
  }

////////////////////////////////////
  ///底部导航栏
///////////////////////////////////
  Future<void> showBottomSheetDialog() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return Container(
                height: 40,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  //纲要
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
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            pause(setDialogState);
                            routePush(ReadingSettings(true, showSpeechControl: true)).then((value) {
                              updateSetting();
                            });
                          })
                    ],
                  )
                ]));
          });
        });
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
        if (mixedList.length <= currentIndex) {
          pause(setDialogState);
        } else {
          play(setDialogState);
        }
      });
    }

    if (mixedList.length > currentIndex) {
      flutterTts.speak(mixedList[currentIndex].content);
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
  ///
  ///

  AutoScrollTag wrapScrollWidget(int index) {
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
        color: (mixedList[index].mark == "" || mixedList[index].mark == null) ? Colors.transparent : UtilFunction.stringToColor(mixedList[index].mark),
        child: Column(children: <Widget>[
          SizedBox(height: 5.0),
          GestureDetector(child: createWidget(index), onLongPress: () => longPressParagraph(index)),
          SizedBox(height: 5.0),
        ]));
  }

  /// 这是一个大类 TODO: 需要在之后被重新拆分,但是现在由于代码比较混乱，就先不动
  Widget createWidget(int index) {
//基本内容
    Widget createContent(int index) {
      return ListTile(
        title: Text(
          UtilFunction.indentText(mixedList[index].content, 2),
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

    //角标
    Widget createNote(int index) {
      return ListTile(
        title: Text(
          UtilFunction.indentText(mixedList[index].content, 2),
          textScaleFactor: baseScaleFactor - 0.1,
          textAlign: TextAlign.right,
        ),
      );
    }

//总标题
    Widget createTitle(int index) {
      return ListTile(
          title: Text(
        mixedList[index].content ?? "",
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        textScaleFactor: baseScaleFactor + 0.2,
      ));
    }

//TODO:读经
    Widget createScripture(int index) {
      return ListTile(
        title: Text(
          mixedList[index].content,
          style: TextStyle(color: Colors.blue),
          textScaleFactor: baseScaleFactor - 0.1,
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
          mixedList[index].content,
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//TODO: h2
    Widget createH2(int index) {
      return ListTile(
        title: Text(
          mixedList[index].content,
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//TODO: h3
    Widget createH3(int index) {
      return ListTile(
        title: Text(
          mixedList[index].content,
          textScaleFactor: baseScaleFactor,
        ),
      );
    }

//1
    Widget createHL1(int index) {
      return Container(
          child: ListTile(
        title: Text(
          mixedList[index].content,
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
              UtilFunction.indentText(mixedList[index].content, 1),
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
              UtilFunction.indentText(mixedList[index].content, 2),
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
              UtilFunction.indentText(mixedList[index].content, 2.5),
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
              UtilFunction.indentText(mixedList[index].content, 3),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

    switch (mixedList[index].flag) {
      case "p":
        return createMap(index);
      case "t":
        return createScripture(index);
      case "s":
        return createScripture(index);
      case "n":
        return createNote(index);

      case "c":
        return createContent(index);
      case "h1":
        return createH1(index);
      case "h2":
        return createH2(index);
      case "h3":
        return createH3(index);

      case "o1":
        return createHL1(index);
      case "o2":
        return createHL2(index);
      case "o3":
        return createHL3(index);

      case "z":
        return createTitle(index);
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
    }
    return Text("default");
  }
}
