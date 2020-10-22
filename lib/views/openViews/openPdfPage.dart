import 'dart:io';

import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import "package:flutter/material.dart";
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:da_ka/global.dart';
import 'package:share_extend/share_extend.dart';

class PdfViewer extends StatefulWidget {
  PdfViewer(this.pdfPath);
  final String pdfPath;

  @override
  _PdfViewerState createState() => _PdfViewerState(pdfPath);
}

class _PdfViewerState extends State<PdfViewer> {
  String pdfPath;
  String sharePath;
  bool ready = false;
  String title;

  _PdfViewerState(this.pdfPath) {
    sharePath = pdfPath;
    //改名
    var titles = pdfPath.split("/").last.split(".");
    titles.removeLast();
    title = titles.join(".");
  }

  @override
  void initState() {
    super.initState();
    prepare();
  }

  prepare() {
    UtilFunction.isEncode(pdfPath).then((value) async {
      if (value is bool && (value == true)) {
        List<String> splitted = pdfPath.split("/");
        splitted.insert(splitted.length - 1, "temp");
        pdfPath = splitted.join("/");
        if (!File(pdfPath).existsSync()) {
          await UtilFunction.decodeFile(sharePath, pdfPath);
        }
      }
      setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var blank = Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(APPBAR_HEIGHT),
          child: AppBar(
            title: Text(title),
            actions: <Widget>[IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file"))],
          )),
      body: Container(),
    );
    var pdfView = PDFViewerScaffold(
        primary: true,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(APPBAR_HEIGHT),
            child: AppBar(
              title: Text(title),
              actions: <Widget>[IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file"))],
            )),
        path: pdfPath);

    return !ready ? blank : pdfView;
  }
}
