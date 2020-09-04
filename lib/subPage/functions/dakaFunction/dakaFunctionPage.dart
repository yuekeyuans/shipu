import 'package:da_ka/subPage/functions/dakaFunction/daka_recite_bible.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

class DaKaFunctionPage extends StatefulWidget {
  @override
  _DaKaFunctionPageState createState() => _DaKaFunctionPageState();
}

class _DaKaFunctionPageState extends State<DaKaFunctionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("打卡设置")),
      body: ListView(
        children: <Widget>[
          ListTile(
              title: Text("背经"), onTap: () => routePush(DakaReciteBiblePage())),
          Divider(),
        ],
      ),
    );
  }
}
