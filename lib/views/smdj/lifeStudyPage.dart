import 'package:common_utils/common_utils.dart';
import 'package:da_ka/db/lifestudyDb/lifeStudyBookName.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyTable.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/markFunction/markEntity.dart';
import 'package:da_ka/mainDir/functions/noteFunction/noteLifeStudyFunction.dart';
import 'package:da_ka/mainDir/functions/noteFunction/showFootNotesPage.dart';
import 'package:da_ka/mainDir/functions/readingSettingsFunction/ReadingSettings.dart';
import 'package:da_ka/mainDir/functions/readingSettingsFunction/readingSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:da_ka/views/smdj/smdjIndexPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_pickers/helpers/show_swatch_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_extend/share_extend.dart';

// ignore: must_be_immutable
class LifeStudyPage extends StatefulWidget {
  int book = -1;
  int chapter = -1;
  LifeStudyPage({this.book = -1, this.chapter = -1});

  @override
  _LifeStudyPageState createState() => _LifeStudyPageState();
}

class _LifeStudyPageState extends State<LifeStudyPage> {
  double baseScaleFactor = 1.0;

  AutoScrollController controller;
  DateTime date = DateTime.parse(DateUtil.formatDate(DateTime.now(), format: DateFormats.y_mo_d));
  FlutterTts flutterTts;
  List<LifeStudyRecord> records = [];

  /// 篇题名称
  String pageName = "";

  ///false 按篇计算, true 按日期计算
  bool isDaily = true;

  /// book and chapter
  int book, chapter;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom), axis: Axis.vertical, suggestedRowHeight: 200);
    updateSetting();
    //判读是否一年一遍加载进来
    if (widget.book + widget.chapter != -2) {
      isDaily = false;
      book = widget.book;
      chapter = widget.chapter;
    }
    updateData();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

////////////////////////////////////////
  ///数据加载
////////////////////////////////////////
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
    if (isDaily) {
      var time = DateUtil.formatDate(date, format: DateFormats.zh_mo_d);
      pageName = "生命读经-$time";
      records = await LifeStudyTable().queryArticleByDate(date);
    } else {
      records = await LifeStudyTable().queryChapter(bookIndex: book, chapter: chapter);
      pageName = await LifeStudyBookName.queryBookNameById(widget.book);
      pageName += "生命读经";
    }
    setState(() {});
  }

///////////////////////////////////////////
  ///组件构成
///////////////////////////////////////////
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
    var color = MarkEntity.fromJson(records[index].mark).bgColor;
    color = color ?? Colors.transparent;
    bool hasMessage = MarkEntity.fromJson(records[index].mark).notes.isNotEmpty;
    return Container(
        color: color,
        child: Column(children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: GestureDetector(child: createWidget(index), onLongPress: () => longPressParagraph(index))),
              hasMessage
                  ? IconButton(
                      icon: Icon(Icons.message),
                      onPressed: () => routePush(ShowAllFootNotesPage(lifeStudyRecord: records[index])).then((value) => updateData()),
                    )
                  : SizedBox(width: 0.0),
            ],
          ),
        ]));
  }

  //长按效果
  void longPressParagraph(int index) {
    bool isParagraph = !UtilFunction.isNumeric(records[index].flag);
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
            isParagraph
                ? ListTile(
                    dense: true,
                    title: MarkEntity.fromJson(records[index].mark).bgColor == null ? Text("标记背景色") : Text("取消标记背景色"),
                    onTap: () {
                      pop();
                      markBgColor(records[index]);
                    })
                : SizedBox(height: 0.0),
            isParagraph
                ? ListTile(
                    dense: true,
                    title: MarkEntity.fromJson(records[index].mark).textColor == null ? Text("标记文字颜色") : Text("取消标记文字颜色"),
                    onTap: () {
                      pop();
                      markTextColor(records[index]);
                    })
                : SizedBox(height: 0.0),
            isParagraph
                ? ListTile(
                    dense: true,
                    title: Text("添加笔记"),
                    onTap: () {
                      pop();
                      routePush(NoteLifeStudyFunction(records[index])).then((value) => updateData());
                    })
                : SizedBox(height: 0.0),
            ListTile(
                dense: true,
                title: Text("从此处朗读"),
                onTap: () {
                  pop();
                  currentIndex = index;
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
            var children = <Widget>[
              // 播放音频
              playState == 0
                  ? IconButton(icon: Icon(Icons.stop), onPressed: () => play(setDialogState))
                  : IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () => pause(setDialogState),
                    ),
            ];

            if (isDaily) {
              children.addAll([
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
                IconButton(
                  icon: Icon(Icons.view_list_sharp),
                  onPressed: () => routePush(
                    SmdjIndexPage(),
                  ),
                ),
              ]);
            } else {
              children.addAll([
                //后退
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => prevPage(setDialogState),
                ),
                //前进
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => nextPage(setDialogState),
                )
              ]);
            }

            children.add(//设置
                IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      pause(setDialogState);
                      routePush(ReadingSettings(true, showSpeechControl: true, showPlayButtons: true)).then((value) {
                        updateSetting();
                      });
                    }));

            return Container(
                height: 40,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  //打卡
                  IconButton(icon: Icon(Icons.list), onPressed: showOutline),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: children,
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

  ///标记背景色
  Future<void> markBgColor(LifeStudyRecord record) async {
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
  Future<void> markTextColor(LifeStudyRecord record) async {
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
  ///前进后退返回
//////////////////////////

  DateTime get curDate => DateTime.parse(DateUtil.formatDate(DateTime.now(), format: DateFormats.y_mo_d));
  int get todayDifference => curDate.difference(date).inDays;

  //转到今天
  void toToday(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    date = curDate;
    updateData();
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

  //上一天
  void prevDay(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    date = date.add(Duration(days: -1));
    updateData();
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

  //上一篇
  void prevPage(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    var value = LifeStudyTable.queryPrevPageByBookIndexAndChapter(book, chapter);
    if (value.first == -1) {
      showToast("已经是第一篇");
      return;
    }
    book = value.first;
    chapter = value.last;
    updateData();
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

  //下一天
  void nextDay(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    date = date.add(Duration(days: 1));
    updateData();
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

  //下一篇
  void nextPage(StateSetter setDialogState) {
    pause(setDialogState);
    currentIndex = 0;
    var value = LifeStudyTable.queryNextPageByBookIndexAndChapter(book, chapter);
    if (value.first == -1) {
      showToast("已经是最后一篇");
      return;
    }
    book = value.first;
    chapter = value.last;
    updateData();
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

//////////////////////////
  ///音频
//////////////////////////
  int playState = 0;
  int currentIndex = 0;
  StateSetter setDialogState;
  void play(StateSetter setDialogState) {
    flutterTts.completionHandler ??= () {
      if (records.length <= currentIndex) {
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

    if (records.length > currentIndex) {
      flutterTts.speak(records[currentIndex].content);
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
    flutterTts.stop();
    playState = 0;
    currentIndex = currentIndex == 0 ? 0 : currentIndex - 1;
    if (setDialogState != null) {
      setDialogState(() {});
    }
    setState(() {});
  }

//////////////////////////
  /// 文本处理
//////////////////////////
  Widget createContent(int index) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
      title: Text(
        UtilFunction.indentText(records[index].content, 2),
        textScaleFactor: baseScaleFactor,
        style: TextStyle(color: MarkEntity.fromJson(records[index].mark).textColor),
      ),
    );
  }

  ///读经
  Widget createReadingBible(int index) {
    return ListTile(
      title: Text(
        records[index].content,
        style: TextStyle(color: MarkEntity.fromJson(records[index].mark).textColor),
        textScaleFactor: baseScaleFactor,
      ),
    );
  }

  ///:图表
  Widget createMap(int index) {
    return Icon(Icons.map);
  }

  ///: h1
  Widget createH1(int index) {
    return ListTile(
      title: Text(
        records[index].content,
        textScaleFactor: baseScaleFactor,
        style: TextStyle(color: MarkEntity.fromJson(records[index].mark).textColor),
      ),
    );
  }

  ///: h2
  Widget createH2(int index) {
    return ListTile(
      title: Text(
        records[index].content,
        textScaleFactor: baseScaleFactor,
        style: TextStyle(color: MarkEntity.fromJson(records[index].mark).textColor),
      ),
    );
  }

  ///: h3
  Widget createH3(int index) {
    return ListTile(
      title: Text(
        records[index].content,
        textScaleFactor: baseScaleFactor,
        style: TextStyle(color: MarkEntity.fromJson(records[index].mark).textColor),
      ),
    );
  }

  ///纲目内容
  Widget createOutline(int index, int flag) {
    return Container(
      color: Colors.transparent,
      child: Padding(
          padding: EdgeInsets.only(left: flag * 10.0),
          child: ListTile(
            title: Text(
              records[index].content,
              textScaleFactor: baseScaleFactor + (7 - flag) * 0.05,
            ),
          )),
    );
  }

  Widget createWidget(int index) {
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
      default:
        return UtilFunction.isNumeric(records[index].flag) ? createOutline(index, int.parse(records[index].flag)) : SizedBox(height: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.fromHeight(APPBAR_HEIGHT), child: AppBar(title: Text(pageName), actions: <Widget>[Padding(padding: EdgeInsets.only(right: 10), child: IconButton(icon: Icon(Icons.menu), onPressed: showBottomSheetDialog))])),
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
      ),
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
              onPressed: () {},
            )
          : null,
    );
  }
}
