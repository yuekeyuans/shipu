import 'dart:io';
import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:loading_overlay/loading_overlay.dart';
import 'package:nav_router/nav_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:da_ka/global.dart';
import 'fileScanner.dart';

class ScanFilesPage extends StatefulWidget {
  @override
  _ScanFilesPageState createState() => _ScanFilesPageState();
}

class _ScanFilesPageState extends State<ScanFilesPage> {
  var basePath = "";
  BuildContext ctx;
  bool isSearchAll = false;
  bool isLoading = false;
  List<ContentFileInfoTable> existFile = [];
  List<String> files = <String>[];
  List<bool> selected = <bool>[];
  bool showHiddenFile = SpUtil.getBool("scanFile_show_add");

  @override
  void initState() {
    super.initState();
    scanFile();
  }

  Future<void> scanFile() async {
    showHiddenFile = SpUtil.getBool("scanFile_show_add");
    existFile = await ContentFileInfoTable().queryAll();
    files = [];
    FileScanner(
      onProgress: scanProgress,
      onFinish: scanFinish,
      isSearchAll: isSearchAll,
      suffix: suffix,
    ).start();
    setState(() {
      isLoading = true;
    });
  }

  void scanProgress(File file) {
    if (isExistPath(file.path) && showHiddenFile) {
      return;
    }
    setState(() {
      files.add(file.path);
    });
  }

  void scanFinish() {
    setState(() {
      isLoading = false;
    });
    print("finish");
  }

  Future<void> onBarSelected(int index) async {
    var hasSelected = false;
    if (index == 0) {
      pop("canceled");
    } else {
      if (index == 1) {
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
  }

  Future<void> onPopMenuClicked(String index) async {
    if (index == 'searchAll')
      isSearchAll = !isSearchAll;
    else if (index == "showAdded")
      await SpUtil.putBool(
          "scanFile_show_add", !SpUtil.getBool("scanFile_show_add"));

    scanFile();
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
            onSelected: onPopMenuClicked,
            offset: Offset(0, kMinInteractiveDimension),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'searchAll',
                  child: ListTile(
                    leading: Icon(Icons.all_inclusive),
                    title: isSearchAll ? Text("扫描传输文件夹") : Text("全盘扫描"),
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
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Container(
            color: Theme.of(context).brightness == Brightness.light
                ? backgroundGray
                : Colors.black,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: isExistPath(files[index]) ? true : selected[index],
                    onChanged: isExistPath(files[index])
                        ? null
                        : (isCheck) =>
                            setState(() => selected[index] = isCheck),
                    activeColor: Colors.red,
                    title: Text(files[index].split("/").last),
                    subtitle: Text(files[index]),
                    isThreeLine: false,
                    dense: false,
                    selected:
                        isExistPath(files[index]) ? true : selected[index],
                    controlAffinity: ListTileControlAffinity.platform,
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider();
                },
                itemCount: files.length)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: '取消'),
          BottomNavigationBarItem(icon: Icon(Icons.select_all), label: '全选'),
          BottomNavigationBarItem(
              icon: Icon(Icons.tab_unselected), label: '反选'),
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
