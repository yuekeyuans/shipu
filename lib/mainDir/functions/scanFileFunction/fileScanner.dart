import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:da_ka/global.dart';
import 'package:isolate_handler/isolate_handler.dart';

int depth = 0;

void loadSpecificDir(Map<String, dynamic> context) {
  final messenger = HandledIsolate.initialize(context);
  messenger.listen((msg) async {
    var args = msg.toString().split("%%");
    var basePath = args[0];
    var suffixes = stringToList(args[1]);
    for (var sp in subPath) {
      var directory = Directory(basePath + sp);
      if (!directory.existsSync()) {
        continue;
      }
      directory.list().forEach((e) {
        if (e is File) {
          for (var sfx in suffixes) {
            if (e.path.endsWith(sfx)) {
              messenger.send(e.path);
            }
          }
        }
      }).then((a) {
        messenger.send(null);
      });
    }
  });
}

void loadAllDir(Map<String, dynamic> context) {
  final messenger = HandledIsolate.initialize(context);
  depth = 0;
  messenger.listen((msg) async {
    var args = msg.toString().split("%%");
    var basePath = args[0];
    var suffixes = stringToList(args[1]);
    loadAllDirRecurse(basePath, messenger, suffixes);
  });
}

void loadAllDirRecurse(
    String path, HandledIsolateMessenger messenger, List<String> suffixes) {
  depth++;
  var directory = Directory(path);
  directory.list().forEach((e) async {
    if (e is File) {
      if (suffixes.isEmpty) {
        messenger.send(e.path);
      } else {
        for (var sfx in suffixes) {
          if (e.path.endsWith(sfx)) {
            messenger.send(e.path);
          }
        }
      }
    } else {
      await loadAllDirRecurse(e.path, messenger, suffixes);
    }
  }).then((value) {
    depth--;
    if (depth == 0) {
      messenger.send(null);
    }
  });
}

String listToString(List<String> list) {
  if (list == null) {
    return "";
  }
  String result;
  list.forEach((string) =>
      {if (result == null) result = string else result = '$result,$string'});
  return result.toString();
}

List<String> stringToList(String list) {
  return list.split(',');
}

class FileScanner {
  void Function(String file) onProgress;
  void Function() onFinish;
  List<String> suffixes;
  List<File> selectedPath = [];
  bool isSearchAll = false;
  String path;
  static int depth = 0;

  final isolates = IsolateHandler();

  FileScanner(
      {void Function(String file) onProgress,
      void Function() onFinish,
      List<String> suffixes = const [],
      bool isSearchAll = false,
      String path = ""}) {
    this.onProgress = onProgress;
    this.onFinish = onFinish;
    this.suffixes = suffixes;
    this.isSearchAll = isSearchAll;
    this.path = path;
  }

  void receiveFile(String f) {
    if (f != null) {
      onProgress(f);
    } else {
      onFinish();
      isolates.kill('path');
    }
  }

  Future<void> start() async {
    var basePath = SpUtil.getString("GLOBAL_PATH");
    var sendPath = basePath + "%%" + listToString(suffixes);
    depth = 0;
    if (!isSearchAll) {
      // search defined address
      isolates.spawn<String>(
        loadSpecificDir,
        name: "loadSpecific",
        onReceive: this.receiveFile,
        onInitialized: () => isolates.send(sendPath, to: 'loadSpecific'),
      );
    } else {
      // print("search all");
      isolates.spawn<String>(
        loadAllDir,
        name: "loadAll",
        onReceive: this.receiveFile,
        onInitialized: () => isolates.send(sendPath, to: 'loadAll'),
      );
    }
  }
}
