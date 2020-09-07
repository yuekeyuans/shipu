import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';

class UtilFunction {
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
      return new File(path).writeAsBytesSync(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    };
    return writeToFile(bytes, dest);
  }
}