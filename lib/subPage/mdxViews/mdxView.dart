import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:da_ka/subPage/mdxViews/mdxDict.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../global.dart';
import 'mdxEntry.dart';
import 'mdxSqlite.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MdxViewer extends StatefulWidget {
  MdxViewer(this.mdxPath);

  final String mdxPath;

  @override
  _MdxViewerState createState() => _MdxViewerState(this.mdxPath);
}

class _MdxViewerState extends State<MdxViewer> {
  _MdxViewerState(this.mdxPath);

  String dictHtml = "";
  List<MdxEntry> entries = [];
  MdxEntry entry;
  FlutterTts flutterTts = FlutterTts();
  var fontSize = 16;
  bool isShow = true;
  String languageAvailableText = '';
  List<String> languages;
  String mdxPath;
  Random rng = new Random();
  String searchText;
  final TextEditingController speechTextController =
      new TextEditingController();

  bool startPlay = false;
  String titleName;
  WebView view;

  final _controller = Completer<WebViewController>();
  var _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    titleName = mdxPath.split("/").last.split(".").first;
    MdxDb().setPath(mdxPath);
    updateInfo();
    flutterTts.setLanguage("zh-CN");
  }

  Future<void> updateInfo() async {
    entries = await MdxEntry().queryIndexesBySearch(searchText);
    dictHtml = await MdxDict().queryHtml();
    updatePage();
    setState(() {});
  }

  updatePage() async {
    String html;
    if (entry == null) {
      html = dictHtml == null ? "" : dictHtml;
    } else {
      html = (await entry.load()).html;
    }
    var uri = Uri.dataFromString(parseHtml(html),
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
    _controller.future.then((value) => value.loadUrl(uri.toString()));
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

  Widget getBottomNaviBar() {
    return isShow
        ? GestureDetector(
            child: Container(
                height: MDX_BOTTOM_HEIGHT,
                color: Color.fromARGB(10, 200, 200, 200),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(children: <Widget>[
                        SizedBox(width: 10),
                        GestureDetector(
                            child: Icon(Icons.menu, color: MDX_ICON_COLOR),
                            onTap: () =>
                                _scaffoldkey.currentState.openDrawer()),
                      ]),
                      Row(children: <Widget>[
                        SizedBox(width: 10),
                        GestureDetector(
                            child: Icon(Icons.zoom_in, color: MDX_ICON_COLOR),
                            onTap: () {
                              fontSize += 2;
                              updatePage();
                            }),
                        SizedBox(width: 10),
                        GestureDetector(
                          child: Icon(Icons.zoom_out, color: MDX_ICON_COLOR),
                          onTap: () => _scaffoldkey.currentState.setState(() {
                            fontSize -= 2;
                            updatePage();
                          }),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          child: Icon(
                              startPlay ? Icons.play_arrow : Icons.pause,
                              color: MDX_ICON_COLOR),
                          onTap: () async {
                            if (entry != null &&
                                entry.text != null &&
                                entry.text != "") {
                              if (!startPlay) {
                                await flutterTts.speak(entry.text);
                                startPlay = !startPlay;
                              } else {
                                await flutterTts.stop();
                                startPlay = !startPlay;
                              }
                              setState(() {});
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          child: Icon(Icons.home, color: MDX_ICON_COLOR),
                          onTap: () {
                            entry = null;
                            updatePage();
                          },
                        ),
                        SizedBox(width: 10),
                      ])
                    ])),
            onTap: () {
              setState(() {
                isShow = !isShow;
              });
            },
          )
        : GestureDetector(
            child: Opacity(
                opacity: 1.0,
                child: Container(
                    height: MDX_BOTTOM_HEIGHT, color: Colors.transparent)),
            onTap: () {
              setState(() {
                isShow = !isShow;
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
        javascriptChannels: <JavascriptChannel>[].toSet(),
        navigationDelegate: (NavigationRequest request) {
          print(request.url);
          if (request.url.startsWith('entry:')) {
            print(request.url);
            var url = request.url;
            var id = (url.split("#")[0]).split("/").last;
            setState(() async {
              entry = await MdxEntry().queryFromId(id);
              print(entry.toJson());
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
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: Colors.black)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: PreferredSize(
          child: AppBar(
            title: Text(
              titleName,
              style: TextStyle(fontSize: 14),
            ),
            automaticallyImplyLeading: false,
          ),
          preferredSize: Size.fromHeight(APPBAR_HEIGHT - 20)),
      body: getWebView(),
      drawer: Drawer(
          child: Padding(
              padding: EdgeInsets.only(top: 30, left: 6, right: 6),
              child: Column(children: [
                getFSearchBox(),
                Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(entries[index].entry),
                            onTap: () {
                              entry = entries[index];
                              updatePage();
                              Navigator.of(context).pop();
                            },
                            dense: true,
                          );
                        },
                        separatorBuilder: (context, index) =>
                            Divider(height: 1),
                        itemCount: entries.length))
              ]))),
      bottomNavigationBar: getBottomNaviBar(),
    );
  }
}
