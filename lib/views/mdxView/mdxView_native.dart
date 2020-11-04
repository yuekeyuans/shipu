import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:nav_router/nav_router.dart';

import 'package:da_ka/db/mdx/mdxDict.dart';
import 'package:da_ka/db/mdx/mdxEntry.dart';
import 'package:da_ka/db/mdx/mdxSqlite.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/DakaSettings.dart';
import 'package:da_ka/mainDir/functions/dakaSettings/dakaSettingsEntity.dart';
import 'package:da_ka/mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:da_ka/views/mdxView/MdxViewIndexNext.dart';

class MdxViewer extends StatefulWidget {
  MdxViewer(this.mdxPath);
  final String mdxPath;

  @override
  _MdxViewerState createState() => _MdxViewerState();
}

class _MdxViewerState extends State<MdxViewer> {
  MdxEntry entry;
  FlutterTts flutterTts;
  List<String> contents;
  List<WebViewHistory> webviewHistory = [];
  int webviewHistoryIndex = -1;
  double fontSize = 16.0;
  String mdxPath;
  String sharePath;
  String title;
  String pageAnchor = "";
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  _MdxViewerState();

  @override
  void initState() {
    createWebView();
    updateSetting();
    MdxViewIndex(onItemClick, widget.mdxPath);
    prepareDb();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updatePage();
    }); //执行yourFunction

//监听webview状态改变
    flutterWebviewPlugin.onStateChanged.listen((s) async {
      if (s.type == WebViewState.shouldStart) {
        await flutterWebviewPlugin.stopLoading(); //停止加载
        await flutterWebviewPlugin.clearCache();
        await clearWebviewSelfHistory();
        //拦截即将展现的页面
        if (s.url.startsWith("entry://")) {
          //向页面添加内容
          webviewHistory = webviewHistory.getRange(0, webviewHistoryIndex + 1).toList();
          webviewHistory.add(WebViewHistory(id: 0, url: s.url));
          webviewHistoryIndex++;
          var result = await buildEntry(s.url);
          entry = result.last as MdxEntry;
          updatePage(anchor: result.first as String);
          return;
        }
      } else if (s.type == WebViewState.finishLoad) {
        if (pageAnchor != "") {
          flutterWebviewPlugin.evalJavascript("window.location.hash='$pageAnchor'");
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    flutterWebviewPlugin.close();
    if (flutterTts != null) {
      flutterTts.stop();
    }
    super.dispose();
  }

  Timer _timer;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          pop(); //点击直接退出，没有后退选项
          return Future.value(false);
        },
        child: Scaffold(
          appBar: PreferredSize(
            child: AppBar(
                leading: Builder(builder: (context) {
                  return IconButton(
                      icon: Icon(Icons.directions_railway),
                      onPressed: () {
                        hideWeb();
                        _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
                          if (!Scaffold.of(context).isDrawerOpen) {
                            showWeb();
                            _timer.cancel();
                          }
                        });
                        Scaffold.of(context).openDrawer();
                      });
                }),
                title: Text(title),
                actions: [
                  IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        if (setWebViewState != null) {
                          setWebViewState(() => isShowBottomSheet = !isShowBottomSheet);
                        }
                      }),
                ]),
            preferredSize: Size.fromHeight(APPBAR_HEIGHT),
          ),
          body: createWebView(),
          drawer: buildDrawer(),
          drawerEnableOpenDragGesture: false,
        ));
  }

/////////////////////////////////////////////////
  ///历史操作  跳转操作
/////////////////////////////////////////////////
  Future<void> goBackHistory(StateSetter setDialogState) async {
    await clearWebviewSelfHistory();
    if (webviewHistoryIndex <= 0) {
      return;
    }
    webviewHistoryIndex--;
    var curUrl = webviewHistory[webviewHistoryIndex];
    if (curUrl.id == 0) {
      var result = await buildEntry(curUrl.url); // id == 0
      entry = result.last as MdxEntry;
      pageAnchor = result.first as String;
      await updatePage(anchor: pageAnchor);
    } else {
      entry == null;
      await updatePage(pageHtml: curUrl.data); // id == 1;
    }
    setDialogState(() {});
  }

  Future<void> goForwardHistory(StateSetter setDialogState) async {
    await clearWebviewSelfHistory();

    if (webviewHistory.length <= webviewHistoryIndex + 1) {
      return; //没有历史记录，无法往前
    } else {
      webviewHistoryIndex++;
      var curUrl = webviewHistory[webviewHistoryIndex];
      if (curUrl.id == 0) {
        var result = await buildEntry(curUrl.url); // id == 0
        entry = result.last as MdxEntry;
        pageAnchor = result.first as String;
        await updatePage(anchor: pageAnchor);
      } else {
        entry == null;
        await updatePage(pageHtml: curUrl.data); // id == 1;
      }
    }
    setDialogState(() {});
  }

  Future<void> clearWebviewSelfHistory() async {
    try {
      while (await flutterWebviewPlugin.canGoBack()) {
        await flutterWebviewPlugin.goBack();
      }
    } catch (e) {
      print(e.toString());
    }
  }

/////////////////////////////////////////////////
  ///webview
/////////////////////////////////////////////////
  bool isShowWebView = true;
  bool isShowBottomSheet = true;
  void showWeb() {
    setState(() {
      isShowWebView = true;
      flutterWebviewPlugin.show();
    });
  }

  void hideWeb() {
    setState(() {
      isShowWebView = false;
      flutterWebviewPlugin.hide();
    });
  }

  Future<List<dynamic>> buildEntry(String url) async {
    var main = url.split("entry://").last;
    var pageAnchor = Uri.decodeComponent(main.split("#").length == 1 ? "" : main.split("#").last);
    var name = Uri.decodeComponent(main.split("#").first.split("/").first);
    var id = main.split("#").first.split("/").last;
    print("anchor $pageAnchor");
    print("name $name");
    print("id $id");
    var e = await MdxEntry(id: id).load();
    return [pageAnchor, e];
  }

  WebviewScaffold _webView;
  Container ctn;
  StateSetter setWebViewState;
  Container createWebView() {
    ctn ??= Container(child: StatefulBuilder(builder: (BuildContext ctx, StateSetter setWebViewState) {
      this.setWebViewState = setWebViewState;
      _webView = WebviewScaffold(
        url: "",
        persistentFooterButtons: isShowBottomSheet ? [createSheet()] : null,
        hidden: true,
        withZoom: true,
        withLocalStorage: true,
        initialChild: Container(
          color: Colors.transparent,
          child: const Center(
            child: SizedBox(height: 0.0),
          ),
        ),
      );
      return _webView;
    }));
    return ctn;
  }

/////////////////////////////////////////////////////////////
  ///初始化和更新
/////////////////////////////////////////////////////////////
  prepareDb() {
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
    });
  }

////////////////////////////////
  ///数据加载，更新和排列
////////////////////////////////
  Future<void> updateSetting() async {
    //更新声音
    flutterTts = FlutterTts();
    var e = DakaSettingsEntity.fromSp();
    await flutterTts.getEngines;
    await flutterTts.setLanguage("zh-hant");
    await flutterTts.setVolume(e.volumn);
    await flutterTts.setPitch(e.pitch);
    await flutterTts.setSpeechRate(e.speechRate);
    fontSize = 16.0 * e.baseFont;
    setState(() {});
  }

  /// pageHtml 直接设置html
  /// anchor 跳转链接
  Future<void> updatePage({String anchor = "", String pageHtml = ""}) async {
    //清空webview 本身的url
    await clearWebviewSelfHistory();
    if (setDialogState != null) {
      setDialogState(() {});
    }
    flutterTts.stop();
    currentIndex = 0;
    String html;
    String name = "_index";
    //判断首页的内容
    if (pageHtml != "") {
      html = pageHtml;
    } else if (entry == null) {
      var dictHtml = await MdxDict().queryHtml();
      if (dictHtml == null || dictHtml == "") {
        List<MdxEntry> firstEntry = await MdxEntry.queryFirstPageEntry();
        if (firstEntry.isNotEmpty) {
          entry = firstEntry.first;
          updatePage();
          return;
        }
      }
      html = (dictHtml == "" || dictHtml == null) ? "<center><h1>$title</h1><br><p>点击左上侧显示词条<p></center>" : dictHtml;
      webviewHistory.add(WebViewHistory(id: 1, data: html));
      webviewHistoryIndex++;
    } else {
      entry = await entry.load();
      pageAnchor = anchor;
      html = entry.html;
      name = entry.entry;
    }
    String path = SpUtil.getString("TEMP_PATH") + "/${name}.html";
    File(path).createSync();
    File(path).writeAsStringSync(html);
    contents = (await UtilFunction.convertHtmlToText(path)).split("。");
    var uri = Uri.dataFromString(parseHtml(html), mimeType: 'text/html', encoding: Encoding.getByName('utf-8'));
    flutterWebviewPlugin.reloadUrl(uri.toString() + "#$pageAnchor");
  }

  StatefulBuilder createSheet() {
    return StatefulBuilder(builder: (context, setDialogState) {
      this.setDialogState = setDialogState;
      var canGoBack = webviewHistoryIndex > 0;
      var canGoForwad = webviewHistoryIndex < webviewHistory.length - 1;
      return Container(
          height: 40,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //退出
                IconButton(icon: Icon(Icons.close), onPressed: pop),
                //后退
                IconButton(icon: Icon(Icons.arrow_back), onPressed: canGoBack ? () async => await goBackHistory(setDialogState) : null),
                //前进
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: canGoForwad ? () async => await goForwardHistory(setDialogState) : null,
                ),
                SizedBox(width: 40),
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
                IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      hideWeb();
                      routePush(DakaSettings()).then((value) {
                        showWeb();
                        pause(setDialogState);
                        updateSetting();
                      });
                    }),
              ],
            )
          ]));
    });
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
    webviewHistory = webviewHistory.getRange(0, webviewHistoryIndex + 1).toList();
    webviewHistory.add(WebViewHistory(id: 0, url: "entry://${Uri.encodeComponent(entry.entry)}/${entry.id}#"));
    webviewHistoryIndex++;
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
      print(flutterTts);
      print(contents[currentIndex]);
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
    } else {
      setState(() {});
    }
  }
}

//记录跳转记录
class WebViewHistory {
  // 0 => data
  // 1 => url
  int id;
  String data;
  String url;
  WebViewHistory({
    this.id,
    this.data,
    this.url,
  });

  WebViewHistory copyWith({
    int id,
    String data,
    String url,
  }) {
    return WebViewHistory(
      id: id ?? this.id,
      data: data ?? this.data,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'url': url,
    };
  }

  @override
  String toString() => 'WebViewHistory(id: $id, data: $data, url: $url)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is WebViewHistory && o.id == id && o.data == data && o.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ data.hashCode ^ url.hashCode;
}
