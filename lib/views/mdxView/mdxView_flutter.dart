import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:da_ka/mainDir/functions/dakaSettings/DakaSettings.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/dakaSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:da_ka/views/mdxView/MdxViewIndexNext.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:share_extend/share_extend.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:da_ka/global.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:da_ka/db/mdx/mdxDict.dart';
import 'package:da_ka/db/mdx/mdxEntry.dart';
import 'package:da_ka/db/mdx/mdxSqlite.dart';

class MdxViewer extends StatefulWidget {
  MdxViewer(this.mdxPath);
  final String mdxPath;

  @override
  _MdxViewerState createState() => _MdxViewerState();
}

class _MdxViewerState extends State<MdxViewer> {
  String dictHtml = "";
  MdxEntry entry;
  FlutterTts flutterTts;
  List<String> contents;
  double fontSize = 16.0;
  String mdxPath;
  String sharePath;
  String searchText;
  String title;
  WebView view;
  final _controller = Completer<WebViewController>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  _MdxViewerState();

  @override
  void initState() {
    super.initState();
    //初始化一下
    MdxViewIndex(onItemClick, widget.mdxPath);
    updateInfo();
    updateData();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: PreferredSize(
        child: AppBar(title: createSheet(setState)),
        preferredSize: Size.fromHeight(APPBAR_HEIGHT),
      ),
      body: Container(color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black, child: getWebView()),
      drawer: buildDrawer(),
    );
  }

  bool isShowButton = false;

/////////////////////////////////////////////////////////////
  ///初始化和更新
/////////////////////////////////////////////////////////////
  updateData() {
    flutterTts.setLanguage("zh-CN");
    mdxPath = widget.mdxPath;
    sharePath = mdxPath;
    var titles = mdxPath.split("/").last.split(".");
    titles.removeLast();
    title = titles.join(".");

    UtilFunction.isEncode(mdxPath).then((value) async {
      if ((value is bool) && (value == true)) {
        List<String> splitted = mdxPath.split("/");
        splitted.insert(splitted.length - 1, "temp");
        mdxPath = splitted.join("/");
        if (!File(mdxPath).existsSync()) {
          await UtilFunction.decodeFile(sharePath, mdxPath);
        }
      }
      MdxDb().setPath(mdxPath);
      dictHtml = await MdxDict().queryHtml();
      await updatePage();
      setState(() {});
    });
  }

  Future<void> updateInfo() async {
    flutterTts = FlutterTts();
    var e = DakaSettingsEntity.fromSp();
    fontSize = 16.0 * e.baseFont;
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);

    setState(() {});
  }

  Future<void> updatePage() async {
    pause(setDialogState);
    currentIndex = 0;
    String html;
    String name = "_index";
    if (entry == null) {
      html = dictHtml ?? "";
    } else {
      entry = await entry.load();
      html = entry.html;
      name = entry.entry;
    }
    String path = SpUtil.getString("TEMP_PATH") + "/${name}.html";
    File(path).createSync();
    File(path).writeAsStringSync(html);
    contents = (await UtilFunction.convertHtmlToText(path)).split("。");
    var uri = Uri.dataFromString(parseHtml(html), mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
    _controller.future.then((value) => value.loadUrl(uri.toString()));
  }

///////////////////////////////////////////////////
  ///底部导航栏
///////////////////////////////////////////////////
  Future<void> showBottomSheetDialog() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return createSheet(setDialogState);
          });
        });
  }

  Container createSheet(StateSetter setDialogState) {
    return Container(
        height: 40,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file")),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 播放音频
              playState == 0 // 停止状态
                  ? IconButton(icon: Icon(Icons.stop), onPressed: () => play(setDialogState))
                  : GestureDetector(child: IconButton(icon: Icon(Icons.play_arrow), onPressed: () => pause(setDialogState))),
              //home
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  entry = null;
                  updatePage();
                },
              ), //设置
              IconButton(icon: Icon(Icons.settings), onPressed: () => routePush(DakaSettings()).then((value) => updateInfo())),
            ],
          )
        ]));
  }

/////////////////////////////////////////////////////
  ///webview
/////////////////////////////////////////////////////
  WebView getWebView() {
    if (view != null) {
      return view;
    } else {
      view = WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
          updatePage();
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('entry:')) {
            var url = request.url;
            var id = (url.split("#")[0]).split("/").last;
            setState(() async {
              entry = await MdxEntry().queryFromId(id);
              updatePage();
            });
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        gestureNavigationEnabled: true,
      );
      return view;
    }
  }

  String parseHtml(String html) {
    if (html.startsWith("<html")) {
      return html;
    } else {
      return """<!DOCTYPE html><html lang='zh-cn'><head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head>
    <body  style="font-family:SimSun; font-size:${fontSize}px;">""" +
          html.replaceAll("\n", " ") +
          """</body></html>""";
    }
  }

/////////////////////////////////////////////////////
  ///drawer
/////////////////////////////////////////////////////
  Drawer buildDrawer() {
    var notificationTop = MediaQuery.of(context).padding.top;
    return Drawer(
        child: Container(
            color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
            child: StatefulBuilder(builder: (context, setDrawerState) {
              return Padding(
                padding: EdgeInsets.only(top: notificationTop + 5, left: 4, right: 0),
                child: MdxViewIndex(onItemClick, mdxPath),
              );
            })));
  }

  Future<void> onItemClick(MdxEntry e) async {
    entry = await MdxEntry(id: e.id).load();
    updatePage();
    Navigator.of(context).pop();
  }

//////////////////////////
  ///音频
//////////////////////////
  int playState = 0;
  int currentIndex = 0;
  StateSetter setDialogState;
  void play(StateSetter setDialogState) {
    flutterTts.completionHandler ??= () {
      if (contents.length <= currentIndex) {
        pause(setDialogState);
        currentIndex = 0;
      } else {
        play(setDialogState);
      }
    };

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
    playState = 0;
    currentIndex = currentIndex == 0 ? 0 : currentIndex - 1;
    if (setDialogState != null) {
      setDialogState(() {});
    }
  }
}
