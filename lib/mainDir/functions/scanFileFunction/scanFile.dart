import 'dart:io';
import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:da_ka/global.dart';

class ScanFilesPage extends StatefulWidget {
  @override
  _ScanFilesPageState createState() => _ScanFilesPageState();
}

class _ScanFilesPageState extends State<ScanFilesPage> {
  var basePath = "";
  BuildContext ctx;
  bool isAllFileSearch = false;
  bool isLoading = true;
  List<ContentFileInfoTable> existFile = [];
  List<String> files = <String>[];
  List<bool> selected = <bool>[];

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future<void> onBarSelected(int index) async {
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
          //判断文件是否加密
          if (SpUtil.getBool("Encryption")) {
            UtilFunction.encodeFile(files[i], filePath);
          } else {
            File(files[i]).copySync(filePath);
            ContentFileInfoTable.fromPath(filePath).insert();
            hasSelected = true;
          }
        }
      }
      if (hasSelected) {
        showToast("添加完成");
      }
      pop("finished");
    }
  }

  Future<void> loadData() async {
    existFile = await ContentFileInfoTable().queryAll();
    files = <String>[];
    isAllFileSearch ? loadGlobal(SpUtil.getString("GLOBAL_PATH")) : loadLocal();
  }

  int fileCount = 0;
  int lastFileCount = 0;
  String zhuhuifuPath = SpUtil.getString("MAIN_PATH");
  void loadGlobal(String path) {
    var directory = Directory(path);
    bool shouldUpdate = false;
    directory.list().forEach((e) {
      if (e is File) {
        for (var sfx in suffix) {
          if (e.path.endsWith(sfx)) {
            if (isExistPath(e.path) && SpUtil.getBool("scanFile_show_add")) {
              continue;
            }
            files.add(e.path);
            shouldUpdate = true;
          }
        }
      } else if (e is Directory && !e.path.contains(zhuhuifuPath)) {
        loadGlobal(e.path);
      }
    }).then((value) {
      if (shouldUpdate) {
        setState(() {});
      }
    });
  }

  void loadLocal() {
    basePath = SpUtil.getString("GLOBAL_PATH");
    for (var sp in subPath) {
      var directory = Directory(basePath + sp);
      if (!directory.existsSync()) {
        continue;
      }
      bool shouldUpdate = false;
      directory.list().forEach((e) {
        if (e is File) {
          for (var sfx in suffix) {
            if (e.path.endsWith(sfx)) {
              if (isExistPath(e.path) && SpUtil.getBool("scanFile_show_add")) {
                continue;
              }
              files.add(e.path);
              shouldUpdate = true;
            }
          }
        }
      }).then((value) {
        if (shouldUpdate) {
          setState(() {});
        }
      });
    }
  }

  Future<void> searchAllSelected(String index) async {
    if (index == 'searchAll') {
      isAllFileSearch = !isAllFileSearch;
    } else if (index == "showAdded") {
      await SpUtil.putBool("scanFile_show_add", !SpUtil.getBool("scanFile_show_add"));
    }
    loadData();
  }

  bool isExistPath(String path) {
    for (var i in existFile) {
      if (i.filename == path.split("/").last) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    if (selected.length != files.length) {
      selected = List<bool>(files.length);
      selected.fillRange(0, files.length, false);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Text("扫描文件 (${files.length})")]),
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
                PopupMenuDivider(height: 1.0),
                CheckedPopupMenuItem(
                  value: "showAdded",
                  checked: SpUtil.getBool("scanFile_show_add"),
                  child: Text("隐藏已添加文件"),
                ),
              ];
            },
          )
        ],
      ),
      body: Container(
          color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
          child: ListView.separated(
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: isExistPath(files[index]) ? true : selected[index],
                  onChanged: isExistPath(files[index]) ? null : (isCheck) => setState(() => selected[index] = isCheck),
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
              itemCount: files.length)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: '取消'),
          BottomNavigationBarItem(icon: Icon(Icons.select_all), label: '全选'),
          BottomNavigationBarItem(icon: Icon(Icons.tab_unselected), label: '反选'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: '确定'),
        ],
        currentIndex: 0,
        onTap: onBarSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black54,
      ),
    );
  }
}
