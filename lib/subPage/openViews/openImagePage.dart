import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_extend/share_extend.dart';

import '../../global.dart';

class ImageViewer extends StatefulWidget {
  final String imagePath;
  ImageViewer(this.imagePath);

  @override
  _ImageViewerState createState() => _ImageViewerState(this.imagePath);
}

class _ImageViewerState extends State<ImageViewer> {
  String imagePath;

  _ImageViewerState(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(APPBAR_HEIGHT), child: AppBar(title: Text(imagePath.split("/").last), actions: <Widget>[IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(imagePath, "file"))])),
        body: PhotoView(imageProvider: FileImage(File(imagePath))));
  }
}
