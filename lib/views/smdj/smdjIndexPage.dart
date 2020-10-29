import 'package:da_ka/global.dart';
import 'package:da_ka/views/smdj/smdjViewer.dart';
import 'package:flutter/material.dart';

import 'package:da_ka/db/lifestudyDb/LifeStudyOutline.dart';
import 'package:da_ka/db/lifestudyDb/lifeStudyBookName.dart';
import 'package:da_ka/db/lifestudyDb/lifeStudyCatagory.dart';
import 'package:nav_router/nav_router.dart';

class SmdjIndexPage extends StatefulWidget {
  @override
  _SmdjIndexPageState createState() => _SmdjIndexPageState();
}

class _SmdjIndexPageState extends State<SmdjIndexPage> {
  List<LifeStudyOutline> outlines = [];
  List<LifeStudyBookName> bookNames = [];
  List<LifeStudyCatagory> catagories = [];
  List<LifeStudyItem> mixedList = <LifeStudyItem>[];

  @override
  void initState() {
    super.initState();
    updateData();
  }

  Future<void> initData() async {
    if (outlines.length + bookNames.length + catagories.length == 0) {
      outlines = await LifeStudyOutline.queryAllChapterName();
      bookNames = await LifeStudyBookName.queryAllBookNames();
      catagories = await LifeStudyCatagory.queryCatagory();
    }
  }

  Future<void> updateData() async {
    await initData();
    mixedList = [];
    buildCatagories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("生命读经")),
      body: Container(color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black, child: createListView()),
    );
  }

  void buildCatagories() {
    catagories.forEach((element) {
      mixedList.add(LifeStudyItem(type: 0, isFold: element.isFold, catagory: element));
      if (!element.isFold) {
        buildBookNames(element);
      }
    });
  }

  void buildBookNames(LifeStudyCatagory catagory) {
    bookNames.forEach((element) {
      if (catagory.id == 0) {
        // 旧约
        if (element.bookIndex < 40) {
          mixedList.add(LifeStudyItem(type: 1, isFold: element.isFold, bookName: element));
          if (!element.isFold) {
            buildOutlines(element);
          }
        }
      } else {
        if (element.bookIndex >= 40) {
          mixedList.add(LifeStudyItem(type: 1, isFold: element.isFold, bookName: element));
          if (!element.isFold) {
            buildOutlines(element);
          }
        }
      }
      if (!element.isFold) {
        buildOutlines(element);
      }
    });
  }

  void buildOutlines(LifeStudyBookName bookName) {
    outlines.forEach((element) {
      if (element.book_index == bookName.bookIndex) {
        mixedList.add(LifeStudyItem(type: 2, outline: element));
      }
    });
  }

  ListView createListView() {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        var element = mixedList[index];
        if (element.type == 0 || element.type == 1) {
          String name = element.type == 0 ? element.catagory.name : element.bookName.name;
          return InkWell(
              child: ListTile(
                  isThreeLine: false,
                  title: Row(
                    children: [
                      SizedBox(width: element.type * 20.0),
                      PreferredSize(
                          child: PreferredSize(
                            child: element.isFold ? Icon(Icons.arrow_right) : Icon(Icons.arrow_drop_down),
                            preferredSize: Size.fromWidth(10),
                          ),
                          preferredSize: Size.fromWidth(10)),
                      Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w900), textAlign: TextAlign.left)),
                    ],
                  )),
              onTap: () {
                element.isFold = !element.isFold;
                element.type == 0 ? (element.catagory.isFold = element.isFold) : (element.bookName.isFold = element.isFold);
                updateData();
              });
        }
        return InkWell(
            child: ListTile(
              title: Row(children: [
                SizedBox(width: element.type * 20.0 + 20),
                Expanded(child: Text(element.outline.outline)),
              ]),
              dense: false,
              isThreeLine: false,
              contentPadding: EdgeInsets.all(0),
            ),
            onTap: () => routePush(SmdjViewer(element.outline.book_index, element.outline.chapter)));
      },
      itemCount: mixedList.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1);
      },
    );
  }
}

class LifeStudyItem {
  /// 0 => 新约,旧约
  /// 1 => 卷
  /// 2 => 名称
  int type = 0;
  bool isFold = true;
  LifeStudyOutline outline;
  LifeStudyBookName bookName;
  LifeStudyCatagory catagory;
  LifeStudyItem({
    this.type,
    this.isFold,
    this.outline,
    this.bookName,
    this.catagory,
  });

  @override
  String toString() {
    return 'LifeStudyItem(type: $type, isFold: $isFold, outline: $outline, bookName: $bookName, catagory: $catagory)';
  }
}
