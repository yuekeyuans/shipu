import 'dart:io';
import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import "package:flutter/material.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nav_router/nav_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../global.dart';

class ScanFilesPage extends StatefulWidget {
  @override
  _ScanFilesPageState createState() => _ScanFilesPageState();
}

class _ScanFilesPageState extends State<ScanFilesPage> {
  List<String> files = new List<String>();
  List<ContentFileInfoTable> existFile = [];
  List<bool> selected = new List<bool>();
  BuildContext ctx;
  FToast ftoast;

  var basePath = "";

  @override
  void initState() {
    loadData();
    super.initState();
    ftoast = FToast(context);
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    if (selected.length != files.length) {
      selected = new List<bool>(files.length);
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
              icon: Icon(IconData(0xe14c, fontFamily: "MaterialIcons")),
              title: new Text('取消')),
          BottomNavigationBarItem(
              icon: Icon(IconData(0xe1b3, fontFamily: "MaterialIcons")),
              title: new Text('全选')),
          BottomNavigationBarItem(
              icon: Icon(IconData(0xe1b4, fontFamily: "MaterialIcons")),
              title: new Text('反选')),
          BottomNavigationBarItem(
              icon: Icon(Icons.check), title: new Text('确定')),
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
        _showToast();
      }
      pop("finished");
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
          children: [Icon(Icons.check), SizedBox(width: 12.0), Text("添加完成")],
        ));
    ftoast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
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
