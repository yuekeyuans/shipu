import 'dart:io';

import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:da_ka/global.dart';
// import 'package:da_ka/views/mdxView/mdxView_flutter.dart';

import 'package:da_ka/views/mdxView/mdxView_native.dart';
import 'package:da_ka/views/nee/neeIndexPage.dart';
import 'package:da_ka/views/openViews/openDocPage.dart';
import 'package:da_ka/views/openViews/openImagePage.dart';
import 'package:da_ka/views/openViews/openPdfPage.dart';
import 'package:da_ka/views/smdj/smdjIndexPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_extend/share_extend.dart';
import 'package:sticky_and_expandable_list/sticky_and_expandable_list.dart';

class ContentPageByTypes extends StatefulWidget {
  @override
  _ContentPageByTypesState createState() => _ContentPageByTypesState();
}

class _ContentPageByTypesState extends State<ContentPageByTypes> {
  List<FileSection> fileSection = [];

  List<String> icons = [
    "assets/icon/dict.svg",
    "assets/icon/pdf.svg",
    "assets/icon/word.svg",
    "assets/icon/bundle.svg",
  ];
  @override
  void initState() {
    super.initState();
    queryData();
  }

  void queryData() async {
    await ContentFileInfoTable.scanMainDir();
    var smdjFile = ContentFileInfoTable(id: -1, filepath: "生命读经", filename: "生命读经");
    var neeBook = ContentFileInfoTable(id: -2, filepath: "倪柝声文集", filename: "倪柝声文集");

    fileSection = [];
    fileSection.add(FileSection()
      ..header = "字典文件"
      ..items = []
      ..expanded = false);
    fileSection.add(FileSection()
      ..header = "pdf 文件"
      ..items = []
      ..expanded = false);
    fileSection.add(FileSection()
      ..header = "word 文件"
      ..items = []
      ..expanded = false);
    fileSection.add(FileSection()
      ..header = "集成文件"
      ..items = []
      ..expanded = true);

    fileSection[3].items..add(smdjFile)..add(neeBook);

    var lst = await ContentFileInfoTable().queryAll();
    for (var i in lst) {
      if (i.filename.endsWith(".dict")) {
        fileSection[0].items.add(i);
      } else if (i.filename.endsWith(".pdf")) {
        fileSection[1].items.add(i);
      } else if (i.filename.endsWith(".doc") || i.filename.endsWith(".docx")) {
        fileSection[2].items.add(i);
      }
    }
    setState(() {});
  }

  Future<void> deleteFile(ContentFileInfoTable _file) async {
    _file.remove();
    var file = File(_file.filepath);
    if (await file.exists()) {
      file.deleteSync();
    }
    queryData();
  }

  void shareIt(ContentFileInfoTable _file) {
    var file = File(_file.filepath);
    if (file.existsSync()) {
      ShareExtend.share(_file.filepath, "file");
    } else {
      showToast("无法分享");
    }
  }

  void openFile(ContentFileInfoTable _file) {
    //特殊文件
    if (_file.id < 0) {
      if (_file.id == -1) {
        routePush(SmdjIndexPage());
      } else if (_file.id == -2) {
        routePush(NeeIndexPage());
      }
      return;
    }
    _file.updateLastOpenTime();
    if (_file.filename.endsWith(".doc") || _file.filename.endsWith(".docx")) {
      routePush(DocViewer(_file.filepath)).then((value) => queryData());
    } else if (_file.filename.endsWith(".dict")) {
      routePush(MdxViewer(_file.filepath), RouterType.fade).then((value) => queryData());
    } else if (_file.filename.endsWith(".pdf")) {
      routePush(PdfViewer(_file.filepath)).then((value) => queryData());
    } else if (IMAGE_SUFFIX.any((element) => _file.filepath.endsWith(element))) {
      routePush(ImageViewer(_file.filepath)).then((value) => queryData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
        child: createBody(),
      ),
    );
  }

  ExpandableListView createBody() {
    return ExpandableListView(
      builder: SliverExpandableChildDelegate<ContentFileInfoTable, FileSection>(
          sectionList: fileSection,
          headerBuilder: _buildHeader,
          itemBuilder: (context, sectionIndex, itemIndex, index) {
            ContentFileInfoTable item = fileSection[sectionIndex].items[itemIndex];
            return Slidable(
              actionPane: SlidableBehindActionPane(),
              actionExtentRatio: 0.25,
              child: Container(
                  child: ListTile(
                      leading: SvgPicture.asset(icons[sectionIndex], width: 32, height: 32, color: Theme.of(context).disabledColor),
                      title: Text(item.filename ?? ""),
                      onTap: () {
                        print(item);
                        openFile(item);
                      })),
              secondaryActions: <Widget>[
                IconSlideAction(caption: '删除', color: Colors.redAccent, icon: Icons.delete, onTap: () => deleteFile(item)),
                IconSlideAction(caption: '分享', color: Colors.blue, icon: Icons.share, onTap: () => shareIt(item)),
              ],
            );
          }),
    );
  }

  Widget _buildHeader(BuildContext context, int sectionIndex, int index) {
    FileSection section = fileSection[sectionIndex];
    return InkWell(
        child: Container(
            color: Theme.of(context).cardColor,
            height: 40,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              section.header + "  (${section.items.length})",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
        onTap: () {
          setState(() {
            section.setSectionExpanded(!section.isSectionExpanded());
          });
        });
  }
}

class FileSection implements ExpandableListSection<ContentFileInfoTable> {
  bool expanded;
  List<ContentFileInfoTable> items;
  String header;

  @override
  List<ContentFileInfoTable> getItems() {
    return items;
  }

  @override
  bool isSectionExpanded() {
    return expanded;
  }

  @override
  void setSectionExpanded(bool expanded) {
    this.expanded = expanded;
  }
}
