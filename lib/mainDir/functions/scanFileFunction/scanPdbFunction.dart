import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:da_ka/global.dart';

class ScanPdbFunction extends StatefulWidget {
  @override
  _ScanPdbFunctionState createState() => _ScanPdbFunctionState();
}

class _ScanPdbFunctionState extends State<ScanPdbFunction> {
  var pdbs = <PDB>[];
  String basePath = SpUtil.getString("GLOBAL_PATH");

  @override
  void initState() {
    super.initState();
    deleteISiloFiles();
    loadData();
  }

  void loadData() {
    pdbs = <PDB>[];
    isAllFileSearch ? loadGlobal(basePath) : loadLocal();
  }

  void loadLocal() async {
    for (var sp in subPath) {
      var directory = Directory(basePath + sp);
      if (!await directory.exists()) {
        continue;
      }

      directory.list().forEach((e) {
        if (e is File) {
          if (e.path.endsWith(".pdb")) {
            var pdb = PDB(e.path.split("/").last, e.path);
            pdb.copyPath = basePath + ISILO_DIR + pdb.name;
            pdb.exist = File(pdb.copyPath).existsSync();
            pdbs.add(pdb);
          }
        }
      });
    }
    setState(() {});
  }

  var isiloPdbPath = SpUtil.getString("ISILO_PDB_PATH");
  void loadGlobal(String path) {
    var directory = Directory(path);
    directory.list().forEach((e) {
      if (e is File) {
        if (e.path.endsWith(".pdb")) {
          if (!e.path.contains(isiloPdbPath)) {
            var pdb = PDB(e.path.split("/").last, e.path);
            pdb.copyPath = basePath + ISILO_DIR + pdb.name;
            pdb.exist = File(pdb.copyPath).existsSync();
            pdbs.add(pdb);
            setState(() {});
          }
        }
      } else if (e is Directory) {
        loadGlobal(e.path);
      }
    });
  }

  void deleteISiloFiles() async {
    var basePath = (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
    for (var f in ISILO_DELETE_FILES) {
      var file = File(basePath + ISILO_DIR + f);
      if (await file.exists()) {
        file.delete();
      }
    }
  }

  void copy(int index) {
    showDialog(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('添加'),
          content: Text('是否添加到isilo目录？'),
          actions: <Widget>[
            FlatButton(
              child: Text('是'),
              onPressed: () {
                File(pdbs[index].path).copySync(pdbs[index].copyPath);
                setState(() => pdbs[index].exist = true);
                Navigator.of(context).pop();
                showToast("添加成功");
              },
            ),
            FlatButton(
              child: Text('否'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> searchAllSelected(String index) async {
    if (index == 'searchAll') {
      isAllFileSearch = !isAllFileSearch;
    }
    loadData();
  }

  bool isAllFileSearch = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("扫描 pdb 文件"),
          actions: [
            PopupMenuButton(
              onSelected: searchAllSelected,
              offset: Offset(0, kMinInteractiveDimension),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: 'searchAll',
                    child: ListTile(
                      leading: Icon(Icons.all_inclusive),
                      title: isAllFileSearch ? Text("扫描传输文件夹") : Text("全盘扫描"),
                    ),
                  ),
                ];
              },
            )
          ],
        ),
        body: Container(
          color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
          child: ListView.separated(
            itemCount: pdbs.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Icon(Icons.book),
                title: Text(pdbs[index].name),
                subtitle: Text(pdbs[index].path),
                enabled: !pdbs[index].exist,
                onTap: () => copy(index),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          ),
        ));
  }
}

class PDB {
  PDB(this.name, this.path);
  String copyPath;
  bool exist = false;
  String name;
  String path;
}
