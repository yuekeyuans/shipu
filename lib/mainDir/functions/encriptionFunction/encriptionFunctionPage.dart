import 'package:da_ka/global.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flustars/flustars.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';

class EncryptionFunctionPage extends StatefulWidget {
  @override
  _EncryptionFunctionPageState createState() => _EncryptionFunctionPageState();
}

class _EncryptionFunctionPageState extends State<EncryptionFunctionPage> {
  MethodChannel channel = MethodChannel("com.example.clock_in/encription");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("加密文件")),
        body: SettingsList(
          sections: [
            SettingsSection(
              title: "发送模式",
              tiles: [
                SettingsTile.switchTile(
                  title: "分享文件时使用加密模式",
                  onToggle: (bool value) {
                    SpUtil.putBool("Encryption", value);
                    setState(() {});
                  },
                  switchValue: SpUtil.getBool("Encryption"),
                )
              ],
            ),
            SettingsSection(title: "功能", tiles: [
              SettingsTile(
                title: "加密文件",
                onTap: encodeFile,
              ),
              SettingsTile(
                title: "解密文件",
                onTap: decodeFile,
              ),
            ])
          ],
        ));
  }

  Future<String> encodeFileByPath(String path) async {
    var file = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: suffix,
    );
    if (file == null) {
      return "";
    }
    var decodeFilePath =
        SpUtil.getString("ENCRYPTION_PATH") + "/" + file.path.split("/").last;
    channel.invokeMethod("encode", {"src": file.path, "dest": decodeFilePath});
    return "";
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
        SpUtil.getString("ENCRYPTION_PATH") + "/" + file.path.split("/").last;
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
        SpUtil.getString("DECRYPTION_PATH") + "/" + file.path.split("/").last;
    channel.invokeMethod("decode", {"src": file.path, "dest": decodeFilePath});
  }
}
