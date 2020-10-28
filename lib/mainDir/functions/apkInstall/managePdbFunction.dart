import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/scanFileFunction/scanPdbFunction.dart';
import 'package:filesize/filesize.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_extend/share_extend.dart';

class ManagePdbFunction extends StatefulWidget {
  @override
  _ManagePdbFunctionState createState() => _ManagePdbFunctionState();
}

class _ManagePdbFunctionState extends State<ManagePdbFunction> {
  List<PDB> pdbs = [];

  @override
  void initState() {
    super.initState();
    updateData();
  }

  Future<void> updateData() async {
    pdbs = [];
    var isiloPath = SpUtil.getString("ISILO_PDB_PATH");
    var directory = Directory(isiloPath);
    if (!await directory.exists()) {
      return;
    }

    directory.list().forEach((e) {
      if (e is File) {
        if (e.path.endsWith(".pdb")) {
          pdbs.add(PDB(e.path.split("/").last, e.path));
        }
      }
    }).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("已添加 pdb 文件")),
      body: Container(color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black, child: createList()),
    );
  }

  ListView createList() {
    return ListView.separated(
        itemBuilder: (context, index) {
          var pdb = pdbs[index];
          var file = File(pdb.path);
          var time = DateUtil.formatDate(file.lastModifiedSync(), format: DateFormats.zh_y_mo_d);
          return Slidable(
            child: ListTile(
              title: Text(pdb.name),
              subtitle: Text("$time    ${filesize(file.lengthSync())}"),
              trailing: IconButton(icon: Icon(Icons.share), onPressed: () => shareIt(pdb)),
            ),
            actionPane: SlidableBehindActionPane(),
            secondaryActions: [
              IconSlideAction(caption: '分享', color: Colors.blue, icon: Icons.share, onTap: () => shareIt(pdb)),
              IconSlideAction(caption: '删除', color: Colors.red, icon: Icons.delete, onTap: () => deleteIt(pdb)),
            ],
          );
        },
        separatorBuilder: (context, index) {
          return Divider(height: 1.0);
        },
        itemCount: pdbs.length);
  }

  void shareIt(PDB pdb) {
    ShareExtend.share(pdb.path, "file");
  }

  void deleteIt(PDB pdb) {
    File(pdb.path).deleteSync();
    updateData();
  }
}
