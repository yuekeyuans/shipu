import 'dart:io';
import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:da_ka/subPage/openViews/openPdfPage.dart';
import 'package:da_ka/subPage/viewBookPage.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/subPage/mdxViews/mdxView.dart';
import 'package:da_ka/subPage/openViews/openDocPage.dart';
import 'package:da_ka/subPage/openViews/openImagePage.dart';
import "package:flutter_slidable/flutter_slidable.dart";
import 'package:share_extend/share_extend.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContentPageByList extends StatefulWidget {
  @override
  _ContentPageByListState createState() => _ContentPageByListState();
}

class _ContentPageByListState extends State<ContentPageByList> {
  List<ContentFileInfoTable> list = [];
  FToast ftoast;

  @override
  void initState() {
    super.initState();
    ftoast = FToast(context);

    updateTable();
  }

  Future<void> updateTable() async {
    list = await ContentFileInfoTable().queryAll();
    setState(() {});
  }

  Future<void> deleteFile(ContentFileInfoTable _file) async {
    _file.remove();
    var file = File(_file.filepath);
    if (await file.exists()) {
      file.deleteSync();
    }
    updateTable();
  }

  void shareIt(ContentFileInfoTable _file) {
    var file = File(_file.filepath);
    if (file.existsSync()) {
      ShareExtend.share(_file.filepath, "file");
    } else {
      _showToast();
    }
  }

  _showToast() {
    Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.black12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.check), SizedBox(width: 12.0), Text("无法分享")],
        ));
    ftoast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  //创建文件列表
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        var _file = list[index];
        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
              color: Colors.white,
              child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigoAccent,
                    child: Text(_file.filename.split(".").last),
                    foregroundColor: Colors.white,
                  ),
                  title: Text(_file.filename),
                  subtitle: Text(_file.lastopentime),
                  onTap: () {
                    _file.updateLastOpenTime();
                    if (_file.filename.endsWith(".doc") ||
                        _file.filename.endsWith(".docx")) {
                      routePush(DocViewer(_file.filepath))
                          .then((value) => updateTable());
                    } else if (_file.filename.endsWith(".dict")) {
                      routePush(MdxViewer(_file.filepath), RouterType.fade)
                          .then((value) => updateTable());
                    } else if (_file.filename.endsWith(".pdf")) {
                      routePush(PdfViewer(_file.filepath))
                          .then((value) => updateTable());
                    } else if (IMAGE_SUFFIX
                        .any((element) => _file.filepath.endsWith(element))) {
                      routePush(ImageViewer(_file.filepath))
                          .then((value) => updateTable());
                    } else {
                      routePush(ViewBookPage(), RouterType.material)
                          .then((value) => updateTable());
                    }
                  })),
          actions: <Widget>[],
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: '删除',
              color: Colors.redAccent,
              icon: Icons.delete,
              onTap: () => this.deleteFile(_file),
            ),
            IconSlideAction(
              caption: '分享',
              color: Colors.blue,
              icon: Icons.share,
              onTap: () => this.shareIt(_file),
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return Divider(
          height: 1,
        );
      },
    ));
  }

  //按照打开时间
  Widget getViewByOpenTime() {
    return null;
  }

  //按照加入时间排序
  Widget getViewByAddTime() {
    return null;
  }
}
