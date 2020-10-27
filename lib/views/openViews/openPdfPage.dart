import 'dart:io';

import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:da_ka/views/daka/dakaSettings/DakaSettings.dart';
import 'package:da_ka/views/daka/dakaSettings/dakaSettingsEntity.dart';
import "package:flutter/material.dart";
import 'package:da_ka/global.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:share_extend/share_extend.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  FlutterTts flutterTts = FlutterTts();
  String content = "";
  String contentTextPath = "";
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  _PdfViewerState(this.pdfPath) {
    sharePath = pdfPath;
    //改名
    var titles = pdfPath.split("/").last.split(".");
    titles.removeLast();
    title = titles.join(".");

    //文件输出地点
    var contentTitles = pdfPath.split("/");
    contentTitles.insert(contentTitles.length - 1, "temp");
    contentTextPath = contentTitles.join("/") + ".txt";
  }

  @override
  void initState() {
    super.initState();
    prepare();
    updateInfo();
  }

  Future<void> updateInfo() async {
    var e = DakaSettingsEntity.fromSp();
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);
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

      content = await UtilFunction.convertPdfToText(pdfPath, contentTextPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(APPBAR_HEIGHT),
          child: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file")),
              IconButton(icon: Icon(Icons.menu), onPressed: () => showBottomSheetDialog(context)),
            ],
          )),
      body: SfPdfViewer.file(
        File(pdfPath),
        key: _pdfViewerKey,
      ),
    );
    return PDFViewerScaffold(
        primary: true,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(APPBAR_HEIGHT),
            child: AppBar(
              title: Text(title),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file")),
                IconButton(icon: Icon(Icons.menu), onPressed: () => showBottomSheetDialog(context)),
              ],
            )),
        path: pdfPath);
    // return blank;
  }

  int playState = 0;
  //底部导航栏
  void showBottomSheetDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return Container(
                // height: 40,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // 播放音频
                  playState == 0 // 停止状态
                      ? IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: () async {
                            flutterTts.speak(content);
                            playState = 1;
                            flutterTts.setCompletionHandler(() {
                              playState = 0;
                              setDialogState(() {});
                            });
                            setDialogState(() {});
                          },
                        )
                      : GestureDetector(
                          child: IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                flutterTts.stop();
                                playState = 0;
                                setDialogState(() {});
                              }),
                        ),

                  //设置
                  IconButton(icon: Icon(Icons.settings), onPressed: () => routePush(DakaSettings()).then((value) => updateInfo())),
                ],
              )
            ]));
          });
        });
  }
}
