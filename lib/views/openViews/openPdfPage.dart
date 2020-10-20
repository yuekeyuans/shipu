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

  _PdfViewerState(this.pdfPath);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(APPBAR_HEIGHT),
            child: AppBar(
              title: Text(pdfPath.split("/").last),
              actions: <Widget>[IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(pdfPath, "file"))],
            )),
        path: pdfPath);
  }
}
