import 'package:flutter/material.dart';

import 'package:da_ka/db/mdx/mdxEntry.dart';
import 'package:da_ka/db/mdx/mdxTag.dart';

typedef FunctionOneParam = void Function(MdxEntry entry);

class MdxViewIndex extends StatefulWidget {
  final FunctionOneParam onTap;
  final String viewPath;
  MdxViewIndex(this.onTap, this.viewPath);

  @override
  _MdxViewIndexState createState() => _MdxViewIndexState();
}

class _MdxViewIndexState extends State<MdxViewIndex> {
  List<MdxTag> sortedTags = [];
  static List<MdxTag> tags = [];
  static List<MdxEntry> entries = [];
  static String viewPath = "";
  List<ListItem> mixedList = [];

  @override
  void initState() {
    super.initState();

    updateData();
  }

  Future<void> initData() async {
    var tgs = await MdxTag().queryAllTags();
    tags.addAll(tgs);
    tags.forEach((element) {
      element.fold = true;
    });
    var data = await MdxEntry().queryIndexes();
    entries.addAll(data);
  }

  updateData() async {
    if (tags.length + entries.length == 0 || viewPath == null || viewPath == "" || viewPath != widget.viewPath) {
      print("herere");
      print(widget.viewPath);
      viewPath = widget.viewPath;
      tags.clear();
      entries.clear();
      await initData();
    }
    mixedList = [];
    mergeList(MdxTag.TAG_ID_PARENT, 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return createList();
  }

  //将tags 和 entries 合并
  void mergeList(String tagId, int level) {
    tags.forEach((element) {
      if (element.parentId == tagId) {
        mixedList.add(ListItem(type: 1, level: level, tag: element, isFold: element.fold));

        if (!element.fold) {
          mergeList(element.id, level + 1);
        }
      }
    });
    entries.forEach((element) {
      if (element.tagId == tagId) {
        mixedList.add(ListItem(type: 0, level: level, entry: element));
      }
    });
  }

  ListView createList() {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        var element = mixedList[index];
        if (element.type == 0) {
          return InkWell(
              child: ListTile(
                  // 创建entry
                  isThreeLine: false,
                  title: Row(children: [
                    SizedBox(width: (element.level) * 10.0),
                    Expanded(child: Text(element.entry.entry)),
                  ])),
              onTap: () {
                print(element.toString());
                widget.onTap(element.entry);
              });
        }
        return InkWell(
          child: ListTile(
            title: Row(children: [
              SizedBox(width: element.level * 10.0),
              PreferredSize(child: PreferredSize(child: element.isFold ? Icon(Icons.arrow_right) : Icon(Icons.arrow_drop_down), preferredSize: Size.fromWidth(10)), preferredSize: Size.fromWidth(10)),
              Expanded(child: Text("${element.tag.name} ${element.tag.size}", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
            ]),
            dense: false,
            isThreeLine: false,
            contentPadding: EdgeInsets.all(0),
          ),
          onTap: () {
            element.tag.fold = !element.tag.fold;
            element.isFold = element.tag.fold;
            updateData();
          },
        );
      },
      itemCount: mixedList.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1);
      },
    );
  }
}

class ListItem {
  int type = 0;
  int level = 0;
  bool isFold = false;
  MdxEntry entry;
  MdxTag tag;
  ListItem({
    this.type,
    this.level,
    this.isFold,
    this.entry,
    this.tag,
  });

  @override
  String toString() {
    return 'ListItem(type: $type, level: $level, isOpen: $isFold, entry: $entry, tag: $tag)';
  }
}
