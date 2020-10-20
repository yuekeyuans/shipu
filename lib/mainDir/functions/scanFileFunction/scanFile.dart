import 'dart:io';
import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import "package:flutter/material.dart";
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import '../../../global.dart';

class ScanFilesPage extends StatefulWidget {
  @override
  _ScanFilesPageState createState() => _ScanFilesPageState();
}

class _ScanFilesPageState extends State<ScanFilesPage> {
  List<String> files = <String>[];
  List<ContentFileInfoTable> existFile = [];
  List<bool> selected = <bool>[];
  BuildContext ctx;

  var basePath = "";

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    if (selected.length != files.length) {
      selected = List<bool>(files.length);
      selected.fillRange(0, files.length, false);
    }

    return Scaffold(
      appBar: AppBar(title: Text("扫描文件")),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return CheckboxListTile(
              value: isExistPath(files[index]) ? true : selected[index],
              onChanged: isExistPath(files[index])
                  ? null
                  : (isCheck) => setState(() => selected[index] = isCheck),
              activeColor: Colors.red,
              title: Text(files[index].split("/").last),
              subtitle: Text(files[index]),
              isThreeLine: false,
              dense: false,
              selected: isExistPath(files[index]) ? true : selected[index],
              controlAffinity: ListTileControlAffinity.platform,
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: files.length),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.cancel),
              title: Text('取消')),
          BottomNavigationBarItem(
              icon: Icon(Icons.select_all),
              title: Text('全选')),
          BottomNavigationBarItem(
              icon: Icon(Icons.tab_unselected),
              title: Text('反选')),
          BottomNavigationBarItem(
              icon: Icon(Icons.check), title: Text('确定')),
        ],
        currentIndex: 0,
        onTap: onBarSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black54,
      ),
    );
  }

  void onBarSelected(int index) {
    var hasSelected = false;
    if (index == 0) {
      pop("canceled");
    } else if (index == 1) {
      for (int i = 0; i < selected.length; i++) {
        selected[i] = true;
      }
      setState(() {});
    } else if (index == 2) {
      for (int i = 0; i < selected.length; i++) {
        selected[i] = !selected[i];
      }
      setState(() {});
    } else if (index == 3) {
      for (int i = 0; i < selected.length; i++) {
        if (selected[i] && !isExistPath(files[i])) {
          var filePath = "$basePath/zhuhuifu/" + files[i].split("/").last;
          File(files[i]).copySync(filePath);
          ContentFileInfoTable.fromPath(filePath).insert();
          hasSelected = true;
        }
      }
      if (hasSelected) {
        showToast("添加完成");
      }
      pop("finished");
    }
  }

  void loadData() async {
    basePath =
        (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
    existFile = await ContentFileInfoTable().queryAll();

    for (var sp in subPath) {
      var directory = Directory(basePath + sp);
      if (!await directory.exists()) {
        continue;
      }

      directory.list().forEach((e) {
        if (e is File) {
          for (var sfx in suffix) {
            if (e.path.endsWith(sfx)) {
              setState(() => files.add(e.path));
            }
          }
        }
      });
    }

    scanFavorite();
  }

// ignore: todo
//TODO: 这里是放在微信收藏里面的东西，同样需要查找。现在先不实现，
  void scanFavorite() {}

  bool isExistPath(String path) {
    for (var i in existFile) {
      if (i.filename == path.split("/").last) {
        return true;
      }
    }
    return false;
  }
}
