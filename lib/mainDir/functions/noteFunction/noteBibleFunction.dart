import 'package:da_ka/db/bible/bibleContentTable.dart';
import 'package:da_ka/db/bible/bookNameTable.dart';
import 'package:da_ka/mainDir/functions/markFunction/markEntity.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'showFootNotesPage.dart';

class NoteBibleFunction extends StatefulWidget {
  final BibleContentTable bible;

  NoteBibleFunction(this.bible);
  @override
  _NoteBibleFunctionState createState() => _NoteBibleFunctionState();
}

class _NoteBibleFunctionState extends State<NoteBibleFunction> {
  String bookName = "";
  String content = "";

  @override
  void initState() {
    super.initState();
    updateData();
  }

  Future<void> updateData() async {
    bookName = await BibleBookNameTable.queryBookName(widget.bible.bookIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("笔记"),
        actions: [
          IconButton(
            icon: Icon(Icons.all_inbox),
            onPressed: showAllFootNote,
          )
        ],
      ),
      body: createWidget(),
    );
  }

  Widget createWidget() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            ListTile(
              title: Text(widget.bible.content),
              subtitle: Text("$bookName ${widget.bible.chapter}:${widget.bible.section}"),
            ),
            Divider(height: 1.0),
            Divider(height: 1.0),
            Divider(height: 1.0),
            Divider(height: 1.0),
            Divider(height: 1.0),
            TextField(
              controller: TextEditingController(text: content),
              decoration: const InputDecoration(
                hintText: "请输入笔记内容",
                contentPadding: EdgeInsets.all(10.0),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null, //不限制行数
              minLines: 20,
              autofocus: true,
              onChanged: (v) {
                content = v;
              },
            ),
            MaterialButton(
              child: Text("确定添加笔记"),
              onPressed: onNoteAdd,
              minWidth: double.infinity,
            )
          ],
        ),
      ),
    );
  }

  //添加 笔记内容并且返回
  onNoteAdd() {
    if (content.trim().isEmpty) {
      showToast("请输入笔记内容后,点击添加按钮");
      return;
    }
    var entity = MarkEntity.fromJson(widget.bible.mark);
    entity.notes.add(content);
    widget.bible.mark = entity.toJson();
    print(widget.bible.mark);
    widget.bible.setMarked(widget.bible.mark);
    showToast("添加成功");
    pop("finish");
  }

  /// 查看所有笔记
  showAllFootNote() {
    routePush(ShowAllFootNotesPage(widget.bible));
  }
}
