import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:pdf_text/pdf_text.dart';

class UtilFunction {
  static MethodChannel encriptionChannel = MethodChannel("com.example.clock_in/encription");
  static MethodChannel convertChannel = MethodChannel("com.example.clock_in/converter");
  static zip(Directory src, Directory dest) {
    // Zip a directory to out.zip using the zipDirectory convenience method
    // var encoder = ZipFileEncoder();
    // encoder.zipDirectory(dest);
    // Manually create a zip of a directory and individual files.
    // encoder.create('out2.zip');
    // encoder.addDirectory(Directory('out'));
    // encoder.addFile(File('test.zip'));
    // encoder.close();
  }

  static unzip(List<int> bytes, String path) {
    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);
    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File("$path/$filename")
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory("$path/$filename")..create(recursive: true);
      }
    }
  }

  //拷贝文件
  static void copyFile(ByteData bytes, String dest) {
    var writeToFile = (ByteData data, String path) {
      final buffer = data.buffer;
      return File(path).writeAsBytesSync(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    };
    return writeToFile(bytes, dest);
  }

  //判断文件是否加密
  static Future isEncode(String path) async {
    return encriptionChannel.invokeMethod("isEncoded", {"src": path});
  }

  //加密文件
  static void encodeFile(String fromPath, String toPath) async {
    if (File(fromPath).existsSync()) {
      return encriptionChannel.invokeMethod("encode", {"src": fromPath, "dest": toPath});
    }
  }

  //解密文件
  static void decodeFile(String fromPath, String toPath) async {
    if (File(fromPath).existsSync()) {
      encriptionChannel.invokeMethod("decode", {"src": fromPath, "dest": toPath});
    }
  }

  //doc 转 html
  static Future<void> convertDocToHtml(String fromPath, String toPath) async {
    convertChannel.invokeMethod("convertDocToHtml", {"fromPath": fromPath, "toPath": toPath});
  }

  //doc 转 html 进度
  static Future<bool> convertDocToHtmlProcess() async {
    bool ok = false;
    await convertChannel.invokeMethod("convertDocToHtmlProcess").then((value) {
      if (value is bool) ok = value;
    });
    return ok;
  }

  //html 转 text
  static Future<String> convertHtmlToText(String src) async {
    String text = "";
    await convertChannel.invokeMethod("htmlConvertToText", {"src": src}).then((value) => text = value.toString());
    return text;
  }

  //pdf 转 text
  static Future<String> convertPdfToText(String fromPath, String toPath) async {
    var value = "";
    if (File(toPath).existsSync()) {
      return File(toPath).readAsStringSync();
    }
    File(toPath).createSync();
    PDFDoc doc = await PDFDoc.fromPath(fromPath);
    int len = doc.pages.length;
    for (int i = 1; i <= len; i++) {
      var text = await doc.pageAt(i).text;
      value += text;
      File(toPath).writeAsStringSync(text, mode: FileMode.append);
    }
    return value;
  }
}
