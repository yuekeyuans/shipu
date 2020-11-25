import 'package:da_ka/db/lifestudyDb/lifestudyRecord.dart';
import 'package:da_ka/mainDir/functions/markFunction/markEntity.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'showFootNotesPage.dart';

class NoteLifeStudyFunction extends StatefulWidget {
  final LifeStudyRecord lifeStudyRecord;

  NoteLifeStudyFunction(this.lifeStudyRecord);
  @override
  _NoteLifeStudyFunctionState createState() => _NoteLifeStudyFunctionState();
}

class _NoteLifeStudyFunctionState extends State<NoteLifeStudyFunction> {
  String bookName = "";
  String content = "";

  @override
  void initState() {
    super.initState();
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
              title: Text(widget.lifeStudyRecord.content),
              subtitle: Text("生命读经"),
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
    var entity = MarkEntity.fromJson(widget.lifeStudyRecord.mark);
    entity.notes.add(content);
    widget.lifeStudyRecord.setMarked(entity.toJson());
    showToast("添加成功");
    pop("finish");
  }

  /// 查看所有笔记
  showAllFootNote() {
    routePush(ShowAllFootNotesPage(lifeStudyRecord: widget.lifeStudyRecord));
  }
}
