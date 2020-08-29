import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const methodChannel =
      const MethodChannel('com.example.clock_in/converter');

  _DocViewerState(this.docPath);

  @override
  void initState() {
    super.initState();
    updateChannel();
  }

  updateChannel() async {
    if (await File(docPath + ".html").exists()) {
      setState(() {});
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(text: "文件转换中…");
        });

    //调用
    methodChannel.invokeMethod("convertToHtml", {"path": docPath});
    //查询
    Timer.periodic(Duration(seconds: 1), (timer) async {
      methodChannel.invokeMethod("convertProcess").then((value) {
        print(value);
        if (value is String && value == "true") {
          timer.cancel();
          Navigator.pop(context);
          setState(() => updateWebViewPage());
        }
      });
      print(timer.tick);
      if (timer.tick > 60) {
        timer.cancel();
        Navigator.pop(context);
        AlertDialog(
          content: Text("打开失败"),
          actions: <Widget>[
            new FlatButton(
                child: new Text('确认'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getWebView());
  }

  WebView view;
  WebViewController _webViewController;
  WebView getWebView() {
    if (view != null) {
      return view;
    } else {
      view = WebView(
        // initialUrl: 'https://flutter.cn',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) async {
          Completer<WebViewController>().complete(webViewController);
          _webViewController = webViewController;
          updateWebViewPage();
        },
        javascriptChannels: <JavascriptChannel>[
          // _toasterJavascriptChannel(context),
        ].toSet(),
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
        },
        gestureNavigationEnabled: true,
      );
      return view;
    }
  }

  updateWebViewPage() async {
    var filePath = docPath + ".html";
    if (await File(filePath).exists()) {
      _webViewController.loadUrl(Uri.file(filePath).toString());
    }
  }
}

class LoadingDialog extends Dialog {
  final String text;

  LoadingDialog({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Center(
        child: new SizedBox(
          width: 120.0,
          height: 120.0,
          child: new Container(
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new CircularProgressIndicator(),
                new Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: new Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
