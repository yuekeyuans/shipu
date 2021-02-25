import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:da_ka/global.dart';
import 'package:isolate_handler/isolate_handler.dart';

int depth = 0;

void loadSpecificDir(Map<String, dynamic> context) {
  final messenger = HandledIsolate.initialize(context);
  messenger.listen((msg) async {
    var basePath = msg.toString();
    for (var sp in subPath) {
      var directory = Directory(basePath + sp);
      if (!directory.existsSync()) {
        continue;
      }
      directory.list().forEach((e) {
        if (e is File) {
          for (var sfx in suffix) {
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
    var basePath = msg.toString();
    print("message :"+ msg.toString());
      loadAllDirRecurse(basePath, messenger);
    }
  );
}

void loadAllDirRecurse(String path, HandledIsolateMessenger messenger){
  depth ++;
  var directory = Directory(path);
  directory.list().forEach((e) async {
    if (e is File) {
      if (suffix.isEmpty) {
        messenger.send(e.path);
      } else {
        for (var sfx in suffix) {
          if (e.path.endsWith(sfx)) {
            messenger.send(e.path);
          }
        }
      }
    } else {
      await loadAllDirRecurse(e.path, messenger);
    }
  }).then((value) {
    depth--;
    print(depth);
    if (depth == 0) {
      messenger.send(null);
    }
  });
}

class FileScanner {
  void Function(File message) onProgress;
  void Function() onFinish;
  List<String> suffix;
  List<File> selectedPath = [];
  bool isSearchAll = false;
  String path;
  static int depth = 0;

  final isolates = IsolateHandler();

  FileScanner(
      {void Function(File message) onProgress,
      void Function() onFinish,
      List<String> suffix = const [],
      bool isSearchAll = false,
      String path = ""}) {
    this.onProgress = onProgress;
    this.onFinish = onFinish;
    this.suffix = suffix;
    this.isSearchAll = isSearchAll;
    this.path = path;
  }

  void receiveFile(String f){
    print(f);
    if(f != null){
      var file = File(f);
      onProgress(file);
    }else{
      onFinish();
      isolates.kill('path');
    }
  }

  Future<void> start() async {
    var basePath = SpUtil.getString("GLOBAL_PATH");
    depth = 0;
    if (!isSearchAll) {
      print("search specific");
      isolates.spawn<String>(
        loadSpecificDir,
        name: "loadSpecific",
        onReceive: this.receiveFile,
        onInitialized: () => isolates.send(basePath, to: 'loadSpecific'),
      );
    }else{
      print("search all");
      isolates.spawn<String>(
        loadAllDir,
        name: "loadAll",
        onReceive: this.receiveFile,
        onInitialized: () => isolates.send(basePath, to: 'loadAll'),
      );
    }
  }
}
