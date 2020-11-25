import 'package:da_ka/db/bible/bibleContentTable.dart';
import 'package:da_ka/db/bible/bookNameTable.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';
import 'package:da_ka/mainDir/functions/markFunction/markEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ShowAllFootNotesPage extends StatefulWidget {
  final BibleContentTable bible;
  final LifeStudyRecord lifeStudyRecord;
  ShowAllFootNotesPage({this.bible, this.lifeStudyRecord});
  @override
  _ShowAllFootNotesPageState createState() => _ShowAllFootNotesPageState();
}

class _ShowAllFootNotesPageState extends State<ShowAllFootNotesPage> {
  String name = "";
  String content = "";
  MarkEntity mark = MarkEntity();

  @override
  void initState() {
    super.initState();
    updateData();
  }

  Future<void> updateData() async {
    if (widget.bible != null) {
      name = "${await BibleBookNameTable.queryBookName(widget.bible.bookIndex)} ${widget.bible.chapter}:${widget.bible.section}";
      content = widget.bible.content;
      mark = MarkEntity.fromJson(widget.bible.mark);
    } else if (widget.lifeStudyRecord != null) {
      name = "生命读经";
      content = widget.lifeStudyRecord.content;
      mark = MarkEntity.fromJson(widget.lifeStudyRecord.mark);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("显示所有笔记")),
      body: createBody(),
    );
  }

  Widget createBody() {
    var children = <Widget>[
      ListTile(
        title: Text(content),
        subtitle: Text(name),
      ),
      Divider(height: 5.0, thickness: 5.0),
    ];

    mark.notes.forEach((element) {
      children.add(
        Slidable(
          actionPane: SlidableBehindActionPane(),
          child: ListTile(title: Text(element)),
          secondaryActions: [
            IconSlideAction(caption: '删除', color: Colors.redAccent, icon: Icons.delete, onTap: () => deleteFootNote(element)),
          ],
        ),
      );
      children.add(Divider(height: 1.0));
    });

    return SingleChildScrollView(
      child: Container(
        child: Column(children: children),
      ),
    );
  }

  ///删除笔记
  Future<void> deleteFootNote(String element) async {
    showDialog(
        barrierDismissible: false, // 表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示信息"),
            content: Text("您确定要删除吗?"),
            actions: <Widget>[
              FlatButton(
                child: Text("取消"),
                onPressed: () {
                  print("取消");
                  Navigator.of(context).pop("Cancel");
                },
              ),
              FlatButton(
                child: Text("确定"),
                onPressed: () {
                  print("确定");
                  Navigator.of(context).pop("Ok");
                },
              )
            ],
          );
        }).then((value) async {
      if (value == "Ok") {
        mark.notes.remove(element);
        await widget.bible.setMarked(mark.toJson());
        setState(() {});
      }
    });
  }
}
