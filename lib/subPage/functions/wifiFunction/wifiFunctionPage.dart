import 'package:da_ka/subPage/functions/qrFunction/qrCode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nav_router/nav_router.dart';
import 'wifiEntity.dart';

class WifiShareFunctionPage extends StatefulWidget {
  @override
  _WifiShareFunctionPageState createState() => _WifiShareFunctionPageState();
}

class _WifiShareFunctionPageState extends State<WifiShareFunctionPage> {
  var server = WifiServerEntity();
  var client = WifiClientEntity();

  var channel = MethodChannel("com.example.clock_in/wifi");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("网络连接")),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            value: false,
            title: Text("开启网络链接"),
            onChanged: (bool value) {
              // routePush(QrCodePage());
              openAp();
            },
          ),
          ListTile(title: Text("连接到网络")),
          ListTile(title: Text("分享与接收文件"))
        ],
      ),
    );
  }

  void openAp() {
    channel.invokeMethod("openAp");
  }
}
