import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/bible/bibleChapter.dart';
import 'package:da_ka/db/bible/bibleContentTable.dart';
import 'package:da_ka/db/bible/bibleFootnoteTable.dart';
import 'package:da_ka/db/bible/bibleItem.dart';
import 'package:da_ka/db/bible/bibleOutlineTable.dart';
import 'package:da_ka/db/bible/bookNameTable.dart';
import 'package:da_ka/db/mainDb/ynybJyTable.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/markFunction/markEntity.dart';
import 'package:da_ka/mainDir/functions/noteFunction/noteBibleFunction.dart';
import 'package:da_ka/mainDir/functions/noteFunction/showFootNotesPage.dart';
import 'package:da_ka/mainDir/functions/readingSettingsFunction/ReadingSettings.dart';
import 'package:da_ka/mainDir/functions/readingSettingsFunction/readingSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter_material_pickers/helpers/show_swatch_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/services.dart';
import 'package:share_extend/share_extend.dart';

class YnybJyPage extends StatefulWidget {
  @override
  _YnybJyPageState createState() => _YnybJyPageState();
}

class _YnybJyPageState extends State<YnybJyPage> {
  DateTime date = DateTime.now();
  List<BibleContentTable> bibles = [];
  List<BibleChapter> chapters = [];
  List<BibleOutlineTable> outlines = [];
  List<BibleItem> mixedList = [];
  List<BibleFotnoteTable> footNotes = [];
  Map<int, List<int>> biblesIds = {};
  Map<int, List<int>> outlinesIds = {};
  int bookIndex;
  String bookName;
  AutoScrollController controller;
  FlutterTts flutterTts;

  double baseFontScaler = 1.0;
  bool showOutlines;
  bool showFootnotes;

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical);
    updateSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(APPBAR_HEIGHT),
        child: AppBar(
          title: Text("旧约 - ${DateUtil.formatDate(date, format: DateFormats.zh_mo_d)}"),
          actions: <Widget>[IconButton(icon: Icon(Icons.menu), onPressed: showBottomSheetDialog)],
        ),
      ),
      body: createChildren(),
      floatingActionButton: ReadingSettingsEntity.fromSp().floatPlayButton
          ? FloatingActionButton(
              child: // 播放音频
                  playState == 0
                      ? IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: () => play(null),
                        )
                      : IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () => pause(null),
                        ),
              onPressed: () {
                // play(setState);
              },
            )
          : null,
    );
  }

////////////////////////////////
  ///数据加载，更新和排列
////////////////////////////////
  Future<void> updateSetting() async {
    var e = ReadingSettingsEntity.fromSp();
    //更新声音
    flutterTts = FlutterTts();
    flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);
    baseFontScaler = e.baseFont;
    showFootnotes = e.showFootNote;
    showOutlines = e.showOutline;
    updateData();
  }

  updateData() async {
    biblesIds = {};
    outlinesIds = {};
    mixedList = [];
    chapters = [];
    footNotes = [];
    var record = await YnybJyTable().queryByDate(date);
    bibles = await BibleContentTable().queryByIds(record.ids); //bible
    bookIndex = bibles.first.bookIndex;
    bookName = await BibleBookNameTable.queryBookName(bookIndex);
    await getBooksAndChapter(); // chapter , bookName;
    bibles.forEach((element) {
      if (!biblesIds.containsKey(element.chapter)) {
        biblesIds[element.chapter] = <int>[];
      }
      biblesIds[element.chapter].add(element.section); //bibleIds
    });

    outlines = await BibleOutlineTable.queryByChaptersAndSections(bookIndex, biblesIds); //outlines
    outlines.forEach((element) {
      if (!outlinesIds.containsKey(element.chapter)) {
        outlinesIds[element.chapter] = <int>[];
      }
      outlinesIds[element.chapter].add(element.section); //outlinesIds
    });

    //注解
    footNotes = await BibleFotnoteTable.queryByChaptersAndSections(bookIndex, biblesIds);
    footNotes.forEach((element) {
      var chapter = element.chapter;
      var section = element.section;
      for (var i = 0; i < bibles.length; i++) {
        if (bibles[i].chapter == chapter && bibles[i].section == section) {
          bibles[i].footNotes.add(element);
          if (element.note == "") {
            element.note = footNotes[footNotes.indexOf(element) - 1].note;
          }
          break;
        }
      }
    });

    mergeList();
    setState(() {});
  }

  Future<void> getBooksAndChapter() async {
    var curChapter = 0;
    bibles.forEach((element) {
      if (element.chapter != curChapter) {
        chapters.add(BibleChapter(element.bookIndex, element.chapter));
        curChapter = element.chapter;
      }
    });
  }

  ///章节
  mergeList() {
    chapters.forEach((element) {
      mixedList.add(BibleItem(id: 0, chapter: element, content: "$bookName第${element.chapterId.toString()}章"));
      mergeBibleContent(element);
    });
  }

  ///圣经节
  void mergeBibleContent(BibleChapter chapter) {
    bibles.forEach((element) {
      if (element.chapter == chapter.chapterId) {
        if (showOutlines) {
          //显示outline 时,才添加outline
          mergeOutline(element);
        }
        mixedList.add(BibleItem(id: 1, bible: element, content: element.content));
      }
    });
  }

  ///纲目
  void mergeOutline(BibleContentTable content) {
    if (outlinesIds.containsKey(content.chapter) && outlinesIds[content.chapter].contains(content.section)) {
      outlines.forEach((element) {
        if (element.chapter == content.chapter && element.section == content.section) {
          mixedList.add(BibleItem(id: 2, outline: element, content: element.outline));
        }
      });
    }
  }

//////////////////////////////////////////////
  ///列表的创建
//////////////////////////////////////////////
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
    var color = Colors.transparent;
    if (mixedList[index].id == 1) {
      color = MarkEntity.fromJson(mixedList[index].bible.mark).bgColor;
      color = color ?? Colors.transparent;
    }
    return Container(
        color: color,
        child: Column(children: <Widget>[
          GestureDetector(child: createItem(index), onLongPress: () => longPressParagraph(index)),
        ]));
  }

  ///
  ListView createChildren() {
    return ListView.separated(
      controller: controller,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return wrapScrollWidget(index);
      },
      separatorBuilder: (context, index) {
        return Divider(height: 1.0);
      },
      itemCount: mixedList.length,
    );
  }

  Widget createItem(int index) {
    var type = mixedList[index].id;
    if (type == 0) {
      return ListTile(
          contentPadding: EdgeInsets.all(5.0),
          title: Text(
            mixedList[index].content,
            textAlign: TextAlign.center,
            textScaleFactor: baseFontScaler + 0.2,
            style: TextStyle(color: Colors.lightBlue),
          ));
    } else if (type == 1) {
      var haseMessage = false;
      if (mixedList[index].bible.mark != "") {
        var mark = MarkEntity.fromJson(mixedList[index].bible.mark);
        haseMessage = mark.notes.isNotEmpty;
      }
      return Container(
          padding: EdgeInsets.fromLTRB(0, 15.0, 5.0, 10.0),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    mixedList[index].bible.section.toString(),
                    textScaleFactor: baseFontScaler,
                  ),
                ),
                Expanded(child: createTextSpan(index)),
                haseMessage
                    ? IconButton(
                        icon: Icon(Icons.message),
                        onPressed: () => routePush(ShowAllFootNotesPage(bible: mixedList[index].bible)).then((value) => updateData()),
                      )
                    : SizedBox(width: 0.0),
              ],
            ),
          ]));
    } else {
      var outline = mixedList[index].outline;
      return Container(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey : Colors.grey[300],
        child: Padding(
            padding: EdgeInsets.only(left: outline.level * 10.0),
            child: ListTile(
              title: Text(
                mixedList[index].content,
                textScaleFactor: baseFontScaler + (6 - outline.level) * 0.1,
              ),
            )),
      );
    }
  }

  ///创建带经文的内容
  Text createTextSpan(int index) {
    var section = mixedList[index].bible;
    var textColor = MarkEntity.fromJson(section.mark).textColor;
    if (!showFootnotes || section.footNotes.isEmpty) {
      return Text(
        section.content,
        softWrap: true,
        maxLines: 10,
        textScaleFactor: baseFontScaler,
        style: TextStyle(color: textColor),
      );
    }
    var remainText = section.content;
    //倒叙方法
    var textSpan = <TextSpan>[];
    section.footNotes.reversed.forEach((e) {
      var location = e.location;
      var rightText = remainText.substring(location - 1);

      textSpan.add(TextSpan(text: rightText, style: TextStyle(color: textColor)));
      textSpan.add(
        TextSpan(
          text: " ${UtilFunction.numberToSuperIndex(e.seq.toString())}",
          style: TextStyle(color: Colors.red),
          recognizer: TapGestureRecognizer()..onTap = () => showFootNoteAlert(e),
        ),
      );
      remainText = remainText.substring(0, location - 1);
    });
    if (remainText.isNotEmpty) {
      textSpan.add(TextSpan(text: remainText, style: TextStyle(color: textColor)));
    }

    return Text.rich(
      TextSpan(text: "", children: textSpan.reversed.toList()),
      textScaleFactor: baseFontScaler,
    );
  }

  Future<void> showFootNoteAlert(BibleFotnoteTable footNote) async {
    String bookName = (await BibleBookNameTable.queryBookName(footNote.bookIndex)).toString();
    String name = "$bookName${footNote.chapter.toString()}:${footNote.section.toString()}注${footNote.seq.toString()}";
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(name),
            contentPadding: EdgeInsets.all(24.0),
            children: [Text(footNote.note, textScaleFactor: baseFontScaler)],
          );
        });
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
            mixedList[index].id == 1
                ? ListTile(
                    dense: true,
                    title: MarkEntity.fromJson(mixedList[index].bible.mark).bgColor == null ? Text("标记背景色") : Text("取消标记背景色"),
                    onTap: () {
                      pop();
                      markBgColor(mixedList[index].bible);
                    })
                : SizedBox(height: 0.0),
            mixedList[index].id == 1
                ? ListTile(
                    dense: true,
                    title: MarkEntity.fromJson(mixedList[index].bible.mark).textColor == null ? Text("标记文字颜色") : Text("取消标记文字颜色"),
                    onTap: () {
                      pop();
                      markTextColor(mixedList[index].bible);
                    })
                : SizedBox(height: 0.0),
            mixedList[index].id == 1
                ? ListTile(
                    dense: true,
                    title: Text("添加笔记"),
                    onTap: () {
                      pop();
                      routePush(NoteBibleFunction(mixedList[index].bible)).then((value) => updateData());
                    })
                : SizedBox(height: 0.0),
            ListTile(
                dense: true,
                title: Text("朗读"),
                onTap: () {
                  pop();
                  currentIndex = index;
                  play(setState);
                })
          ]);
        });
  }

//////////////////////////
  ///功能处理
//////////////////////////
  List<Widget> get outline {
    var widgets = <Widget>[];
    mixedList.forEach((element) {
      if (element.id != 1) {
        var index = mixedList.indexOf(element);
        widgets.add(InkWell(
            child: createItem(index),
            onTap: () {
              controller.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
              pop();
            }));
      }
    });
    return widgets;
  }

  /// 纲目
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

  ///标记背景色
  Future<void> markBgColor(BibleContentTable record) async {
    var mark = MarkEntity.fromJson(record.mark);
    bool isMarked = mark.bgColor == null;
    if (isMarked) {
      Color swatch = Colors.blue;
      //颜色改变
      showMaterialSwatchPicker(
        title: "选取背景色",
        context: context,
        selectedColor: swatch,
        onChanged: (color) => mark.bgColor = color,
        onConfirmed: () async {
          print(mark.toJson());
          await record.setMarked(mark.toJson());
          setState(() {});
        },
      );
    } else {
      mark.bgColor = null;
      print(mark.toJson());
      await record.setMarked(mark.toJson());
      setState(() {});
    }
  }

  ///标记文字颜色
  Future<void> markTextColor(BibleContentTable record) async {
    var mark = MarkEntity.fromJson(record.mark);
    bool isMarked = mark.textColor == null;
    if (isMarked) {
      //颜色改变
      showMaterialSwatchPicker(
        title: "选取文字颜色",
        context: context,
        selectedColor: Colors.black,
        onChanged: (color) => mark.textColor = color,
        onConfirmed: () async {
          print(mark.toJson());
          await record.setMarked(mark.toJson());
          setState(() {});
        },
      );
    } else {
      mark.textColor = null;
      print(mark.toJson());
      await record.setMarked(mark.toJson());
      setState(() {});
    }
  }

//////////////////////////
  ///音频
//////////////////////////
  int playState = 0;
  int currentIndex = 0;
  StateSetter setDialogState;
  void play(StateSetter setDialogState) {
    flutterTts.completionHandler ??= () {
      if (mixedList.length <= currentIndex) {
        if (ReadingSettingsEntity.fromSp().repeatPlay) {
          currentIndex = 0;
          play(setDialogState);
        } else {
          pause(setDialogState);
          currentIndex = 0;
        }
      } else {
        play(setDialogState);
      }
    };

    if (mixedList.length > currentIndex) {
      flutterTts.speak(mixedList[currentIndex].content);
      controller.scrollToIndex(currentIndex, preferPosition: AutoScrollPosition.begin);
      playState = 1;
      currentIndex = currentIndex + 1;
      if (setDialogState != null) {
        setDialogState(() {});
      }
      setState(() {});
    } else {
      currentIndex = 0;
      playState = 0;
      if (setDialogState != null) {
        setDialogState(() {});
      }
      setState(() {});
      flutterTts.stop();
    }
  }

  void pause(StateSetter setDialogState) {
    setDialogState ??= setState;
    flutterTts.stop();
    playState = 0;
    currentIndex = currentIndex == 0 ? 0 : currentIndex - 1;
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

//////////////////////////
  ///前进后退返回
//////////////////////////
  DateTime get curDate => DateTime.parse(DateUtil.formatDate(DateTime.now(), format: DateFormats.y_mo_d));
  int get todayDifference => curDate.difference(date).inDays;

  void toToday(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    date = curDate;
    updateData();
    setDialogState(() {});
  }

  void prevDay(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    date = date.add(Duration(days: -1));
    updateData();
    setDialogState(() {});
  }

  void nextDay(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    date = date.add(Duration(days: 1));
    updateData();
    setDialogState(() {});
  }

////////////////////////////////////
  ///底部导航栏
///////////////////////////////////
  Future<void> showBottomSheetDialog() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            this.setDialogState = setDialogState;
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
                      //后退
                      todayDifference >= 0
                          ? IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () => prevDay(setDialogState),
                            )
                          : IconButton(
                              icon: Icon(Icons.adjust),
                              onPressed: () => toToday(setDialogState),
                            ),
                      //前进
                      todayDifference <= 0
                          ? IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () => nextDay(setDialogState),
                            )
                          : IconButton(
                              icon: Icon(Icons.adjust),
                              onPressed: () => toToday(setDialogState),
                            ),
                      //设置
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            pause(setDialogState);
                            routePush(ReadingSettings(true, showSpeechControl: true, showBibleControl: true, showPlayButtons: true)).then((value) => updateSetting());
                          })
                    ],
                  )
                ]));
          });
        });
  }
}
