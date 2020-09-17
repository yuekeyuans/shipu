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
  var pdbs = List<PDB>();

  @override
  void initState() {
    super.initState();
    deleteISiloFiles();
    loadData();
  }

  void loadData() async {
    var basePath =
        (await getExternalStorageDirectory()).parent.parent.parent.parent.path;

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

  void deleteISiloFiles() async {
    var basePath =
        (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("扫描 pdb 文件")),
      body: ListView.separated(
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
    );
  }
}

class PDB {
  PDB(this.name, this.path);

  String copyPath;
  bool exist = false;
  String name;
  String path;
}
