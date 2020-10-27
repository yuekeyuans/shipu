import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:da_ka/views/daka/dakaSettings/DakaSettings.dart';
import 'package:da_ka/views/daka/dakaSettings/dakaSettingsEntity.dart';
import 'package:da_ka/views/mdxView/MdxViewIndexNext.dart';
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
  List<MdxEntry> entries = [];
  MdxEntry entry;
  FlutterTts flutterTts = FlutterTts();
  double fontSize = 16.0;
  String mdxPath;
  String sharePath;
  String searchText;
  String title;
  WebView view;
  MdxViewIndex viewIndex;
  bool ready = false;
  final TextEditingController speechTextController = TextEditingController();
  final _controller = Completer<WebViewController>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();

  _MdxViewerState();

  @override
  void initState() {
    super.initState();
    viewIndex = MdxViewIndex(onItemClick, widget.mdxPath);
    prepare();
    updateInfo();
  }

  prepare() {
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
      setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    var mdxView = Scaffold(
      key: _scaffoldkey,
      appBar: PreferredSize(
        child: AppBar(title: Text(title), actions: [IconButton(icon: Icon(Icons.add), onPressed: showBottomSheetDialog)]),
        preferredSize: Size.fromHeight(APPBAR_HEIGHT),
      ),
      body: getWebView(),
      drawer: buildDrawer(),
    );

    var blank = Scaffold(
      appBar: PreferredSize(
        child: AppBar(title: Text(title)),
        preferredSize: Size.fromHeight(APPBAR_HEIGHT),
      ),
    );
    return ready ? mdxView : blank;
  }

  Future<void> updateInfo() async {
    var e = DakaSettingsEntity.fromSp();
    fontSize = 16.0 * e.baseFont;
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);

    entries = await MdxEntry().queryIndexesBySearch(searchText);
    dictHtml = await MdxDict().queryHtml();
    await updatePage();
    setState(() {});
  }

  Future<void> updatePage() async {
    String html;
    if (entry == null) {
      html = dictHtml ?? "";
    } else {
      html = (await entry.load()).html;
    }
    var uri = Uri.dataFromString(parseHtml(html), mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
    _controller.future.then((value) => value.loadUrl(uri.toString()));
  }

  int playState = 0;
  //底部导航栏
  Future<void> showBottomSheetDialog() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return Container(
                height: 40,
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  // IconButton(icon: Icon(Icons.menu), onPressed: () => _scaffoldkey.currentState.openDrawer()),
                  IconButton(icon: Icon(Icons.share), onPressed: () => ShareExtend.share(sharePath, "file")),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // 播放音频
                      playState == 0 // 停止状态
                          ? IconButton(
                              icon: Icon(Icons.stop),
                              onPressed: () async {
                                flutterTts.speak(entry.text);
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
          });
        });
  }

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
        javascriptChannels: <JavascriptChannel>{},
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

  Widget getFSearchBox() {
    return Container(
      height: 35,
      alignment: Alignment(1, 0.15),
      color: Color.fromARGB(30, 100, 100, 100),
      child: TextFormField(
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Colors.black)),
          contentPadding: EdgeInsets.all(0.0),
          fillColor: Colors.transparent,
          filled: true,
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onChanged: (v) {
          searchText = v;
          updateInfo();
        },
      ),
    );
  }

  Drawer buildDrawer() {
    var notificationTop = MediaQuery.of(context).padding.top;
    return Drawer(
        child: Padding(
      padding: EdgeInsets.only(top: notificationTop + 5, left: 4, right: 0),
      // child: Column(children: [
      //   // getFSearchBox(),
      //   //buildDataList(),
      //   buidDataList1(),
      // ]),
      child: buildDataList1(),
    ));
  }

  Future<void> onItemClick(MdxEntry e) async {
    entry = await MdxEntry(id: e.id).load();
    updatePage();
    Navigator.of(context).pop();
  }

  Widget buildDataList1() {
    return viewIndex;
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
}
