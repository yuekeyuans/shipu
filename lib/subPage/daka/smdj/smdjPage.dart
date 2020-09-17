import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyTable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class SmdjPage extends StatefulWidget {
  @override
  _SmdjPageState createState() => _SmdjPageState();
}

class _SmdjPageState extends State<SmdjPage> {
  List<LifeStudyRecord> records = [];

  DateTime curDate = DateTime.now();
  double baseScaleFactor = 1.2;

  AutoScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical,
        suggestedRowHeight: 200);
    update();
  }

  update() async {
    records = await LifeStudyTable().queryChapter();
    setState(() {});
  }

  int counter = 30;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("生命读经"), actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right: 10),
            child:
                IconButton(icon: Icon(Icons.menu), onPressed: showBottomSheet))
      ]),
      body: Scrollbar(
          child: ListView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children:
            records.map((e) => wrapScrollWidget(records.indexOf(e))).toList(),
      )),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await controller.scrollToIndex(counter,
                preferPosition: AutoScrollPosition.begin);
            controller.highlight(counter, highlightDuration: Duration(days: 1));
            counter++;
          },
          child: Icon(Icons.headset)),
    );
  }

  Widget wrapScrollWidget(int index) {
    return AutoScrollTag(
      key: ValueKey(index),
      controller: controller,
      index: index,
      child: wrapOperationWidget(index),
      highlightColor: Colors.black.withOpacity(0.1),
    );
  }

  Widget wrapOperationWidget(int index) {
    return Container(
        child: Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        GestureDetector(
          child: createWidget(index),
          onLongPress: () {
            longPressParagraph(index);
          },
        ),
        SizedBox(height: 5.0)
      ],
    ));
  }

  void longPressParagraph(int index) {
    controller.highlight(index);
    print(controller.position);
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              ListTile(
                dense: true,
                title: Text("标记"),
              ),
              ListTile(
                dense: true,
                title: Text("复制"),
                onTap: () {
                  pop();
                  Clipboard.setData(
                      new ClipboardData(text: records[index].content));
                  showToast("复制成功");
                },
              ),
              ListTile(
                dense: true,
                title: Text("朗读"),
              )
            ],
          );
        });
  }

  /// 这是一个大类 TODO: 需要在之后被重新拆分,但是现在由于代码比较混乱，就先不动
  Widget createWidget(int index) {
    //缩进文本
    String indent(String content, double size) {
      return "                                                                                                    "
              .substring(0, (size * 4).toInt()) +
          content;
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
    Widget createTitle(index) {
      return ListTile(
          title: Text(
        records[index].content,
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        textScaleFactor: baseScaleFactor + 0.2,
      ));
    }

//TODO:读经
    Widget createReadingBible(index) {
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
        title: Text(records[index].content),
      );
    }

//TODO: h2
    Widget createH2(int index) {
      return ListTile(
        title: Text(records[index].content),
      );
    }

//TODO: h3
    Widget createH3(int index) {
      return ListTile(
        title: Text(records[index].content),
      );
    }

//1
    Widget createHL1(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.grey[200]),
          child: ListTile(
            title: Text(
              records[index].content,
              style: TextStyle(color: Colors.black),
              textScaleFactor: baseScaleFactor + 0.2,
            ),
          ));
    }

//2
    Widget createHL2(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              records[index].content,
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: baseScaleFactor + 0.1,
            ),
          ));
    }

//3
    Widget createHL3(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              records[index].content,
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

//4
    Widget createHL4(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 1),
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

//5
    Widget createHL5(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 1),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor + 0.05,
            ),
          ));
    }

//6
    Widget createHL6(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 1),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor,
            ),
          ));
    }

//7
    Widget createHL7(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 1.5),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor - 0.05,
            ),
          ));
    }

//8
    Widget createHL8(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 1.5),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor - 0.1,
            ),
          ));
    }

//9
    Widget createHL9(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 2),
              style: TextStyle(fontWeight: FontWeight.normal),
              textScaleFactor: baseScaleFactor - 0.1,
            ),
          ));
    }

//10
    Widget createHL10(int index) {
      return new Container(
          decoration: new BoxDecoration(color: Colors.transparent),
          child: ListTile(
            title: Text(
              indent(records[index].content, 2),
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
}
