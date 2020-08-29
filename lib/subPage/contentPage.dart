import 'dart:io';

import 'package:da_ka/db/contentFileInfoTable.dart';
import 'package:da_ka/subPage/openViews/openPdfPage.dart';
import 'package:da_ka/subPage/viewBookPage.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:path_provider/path_provider.dart';

import '../global.dart';
import 'mdxViews/mdxView.dart';
import 'openViews/openDocPage.dart';
import 'openViews/openImagePage.dart';
import "package:flutter_slidable/flutter_slidable.dart";
import 'package:share_extend/share_extend.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContentPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  List<ContentFileInfoTable> list = [];
  FToast ftoast;

  @override
  void initState() {
    super.initState();
    ftoast = FToast(context);
    scanMainDir();
    updateTable();
  }

  Future<void> updateTable() async {
    list = await ContentFileInfoTable().queryAll();
    setState(() {});
  }

  void scanMainDir() async {
    //根目录文件
    var basePath =
        (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
    var existFile = await ContentFileInfoTable().queryAll();

    existFile.forEach((element) async {
      if (!await File(element.filepath).exists()) {
        element.remove();
      }
    });
    existFile = await ContentFileInfoTable().queryAll();

    var directory = Directory(basePath + "/zhuhuifu");
    directory.list().forEach((e) {
      if (e is File) {
        var path = e.path;
        if (!existFile.any((el) => el.filename == path.split("/").last)) {
          if (suffix.any((element) => path.endsWith(element))) {
            ContentFileInfoTable.fromPath(path).insert();
          }
        }
      }
    });
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
}
