import 'dart:async';
import 'dart:io';

import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/DakaSettings.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/dakaSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:share_extend/share_extend.dart';
import 'package:webview_flutter/webview_flutter.dart';

//TODO: 这个文件先编辑到这里，之后会使用破解包和去除水印等操作。
class DocViewer extends StatefulWidget {
  final String docPath;
  DocViewer(this.docPath);

  @override
  _DocViewerState createState() => _DocViewerState(docPath);
}

class _DocViewerState extends State<DocViewer> {
  String docPath;
  String sharePath;
  String docHtmlPath;
  String title;
  String content = "";
  List<String> contents;
  FlutterTts flutterTts = FlutterTts();

  _DocViewerState(this.docPath) {
    sharePath = docPath;
    //改名
    var titles = docPath.split("/").last.split(".");
    titles.removeLast();
    title = titles.join(".");
  }

  @override
  void initState() {
    super.initState();
    preProcessFile();
    updateInfo();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> updateInfo() async {
    var e = DakaSettingsEntity.fromSp();
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);
  }

  Future<void> preProcessFile() async {
    var splitted = docPath.split("/");
    splitted.insert(splitted.length - 1, "temp");
    docHtmlPath = "${splitted.join("/")}.html";
    UtilFunction.isEncode(docPath).then((value) async {
      if (value is bool) {
        if (value == true) {
          var splitted = docPath.split("/");
          splitted.insert(splitted.length - 1, "temp");
          docPath = splitted.join("/");
          await UtilFunction.decodeFile(sharePath, docPath);
        }
      }
      updateChannel();
    });
  }

  updateChannel() async {
    if (await File(docHtmlPath).exists()) {
      content = await UtilFunction.convertHtmlToText(docHtmlPath);
      contents = content.split("。");
      setState(() {});
      if (_webViewController != null) {
        updateWebViewPage();
      }
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(text: "文件转换中…");
        });

    //调用
    UtilFunction.convertDocToHtml(docPath, docHtmlPath);
    //查询
    Timer.periodic(Duration(seconds: 1), (timer) async {
      var isOk = await UtilFunction.convertDocToHtmlProcess();
      if (isOk) {
        timer.cancel();
        pop();
        await updateWebViewPage();
        content = await UtilFunction.convertHtmlToText(docHtmlPath);
        contents = content.split("。");
        setState(() {});
      }

      if (timer.tick > 120) {
        timer.cancel();
        pop();
        AlertDialog(
          content: Text("打开失败"),
          actions: <Widget>[FlatButton(child: Text('确认'), onPressed: pop)],
        );
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var docView = Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            title: Text(title),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: () => showBottomSheetDialog(context)),
            ],
          ),
          preferredSize: Size.fromHeight(APPBAR_HEIGHT),
        ),
        body: Container(
          color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
          child: getWebView(),
        ));
    return docView;
  }

  WebView view;
  WebViewController _webViewController;
  WebView getWebView() {
    if (view != null) {
      return view;
    } else {
      view = WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) async {
          Completer<WebViewController>().complete(webViewController);
          _webViewController = webViewController;
          updateWebViewPage();
        },
        javascriptChannels: <JavascriptChannel>{},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          scalePage();
        },
        gestureNavigationEnabled: true,
      );
      return view;
    }
  }

  updateWebViewPage() async {
    if (await File(docHtmlPath).exists()) {
      _webViewController.loadUrl(Uri.file(docHtmlPath).toString());
      scalePage();
    }
  }

  void scalePage() {
    var factor = DakaSettingsEntity.fromSp().baseFont;
    _webViewController.evaluateJavascript("document.body.style.zoom=$factor");
  }

  //底部导航栏
  void showBottomSheetDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return Container(
                // height: 40,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file")),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // 播放音频
                  playState == 0 // 停止状态
                      ? IconButton(icon: Icon(Icons.stop), onPressed: () => play(setDialogState))
                      : IconButton(icon: Icon(Icons.play_arrow), onPressed: () => pause(setDialogState)),
                  //设置
                  IconButton(icon: Icon(Icons.settings), onPressed: () => routePush(DakaSettings()).then((value) => updateInfo())),
                ],
              )
            ]));
          });
        });
  }

  int playState = 0;
  int currentIndex = 0;
  bool hasInitHandler = false;
  void play(StateSetter setDialogState) {
    if (!hasInitHandler) {
      hasInitHandler = true;
      flutterTts.setCompletionHandler(() {
        if (contents.length <= currentIndex) {
          pause(setDialogState);
        } else {
          play(setDialogState);
        }
      });
    }

    if (contents.length > currentIndex) {
      flutterTts.speak(contents[currentIndex]);
      playState = 1;
      currentIndex = currentIndex + 1;
      setDialogState(() {});
    } else {
      currentIndex = 0;
      playState = 0;
      setDialogState(() {});
      flutterTts.stop();
    }
  }

  void pause(StateSetter setDialogState) {
    flutterTts.stop();
    hasInitHandler = false;
    playState = 0;
    currentIndex = currentIndex == 0 ? 0 : currentIndex - 1;
    setDialogState(() {});
  }
}

class LoadingDialog extends Dialog {
  final String text;

  LoadingDialog({@required this.text, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Center(
            child: SizedBox(
                width: 120.0,
                height: 120.0,
                child: Container(
                    decoration: ShapeDecoration(
                      color: Color(0xffffffff),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(text),
                        )
                      ],
                    )))));
  }
}
