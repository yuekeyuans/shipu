import 'package:da_ka/global.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

class EncriptionFunctionPage extends StatefulWidget {
  @override
  _EncriptionFunctionPageState createState() => _EncriptionFunctionPageState();
}

class _EncriptionFunctionPageState extends State<EncriptionFunctionPage> {
  MethodChannel channel = MethodChannel("com.example.clock_in/encription");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("加密文件")),
      body: ListView(children: [
        ListTile(
          title: Text("加密文件"),
          onTap: encodeFile,
        ),
        Divider(),
        ListTile(
          title: Text("解密文件"),
          onTap: decodeFile,
        )
      ]),
    );
  }

  Future<void> encodeFile() async {
    var file = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: suffix,
    );
    if (file == null) {
      return;
    }
    var decodeFilePath =
        SpUtil.getString("ENCRIPTION_PATH") + "/" + file.path.split("/").last;
    channel.invokeMethod("encode", {"src": file.path, "dest": decodeFilePath});
  }

  Future<void> decodeFile() async {
    var file = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: suffix,
    );
    if (file == null) {
      return;
    }
    var decodeFilePath =
        SpUtil.getString("DECRIPTION_PATH") + "/" + file.path.split("/").last;
    channel.invokeMethod("decode", {"src": file.path, "dest": decodeFilePath});
  }
}
