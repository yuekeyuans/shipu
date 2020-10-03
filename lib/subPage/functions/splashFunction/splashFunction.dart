import 'package:da_ka/subPage/functions/splashFunction/splahEntity.dart';
import 'package:da_ka/subPage/functions/splashFunction/splashStringPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:nav_router/nav_router.dart';

class SplashFunctionPage extends StatefulWidget {
  @override
  _SplashFunctionPageState createState() => _SplashFunctionPageState();
}

class _SplashFunctionPageState extends State<SplashFunctionPage> {
  var splashEntity = SplashEntity.fromSp();

  Future<void> updatePage() async {
    setState(() {
      splashEntity = SplashEntity.fromSp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("启动页管理")),
      body: ListView(children: <Widget>[
        SwitchListTile(
            value: splashEntity.hasSplash,
            onChanged: (val) {
              setState(() {
                splashEntity.hasSplash = val;
                splashEntity.toSp();
              });
            },
            title: Text("使用启动页")),
        Divider(),
        ListTile(
          title: Text("启动页时间"),
          trailing: Text(
            splashEntity.splashTime.toString() + "秒",
            style: TextStyle(color: splashEntity.hasSplash ? Colors.black : Colors.black26),
          ),
          enabled: splashEntity.hasSplash,
          onTap: () {
            Picker(
                adapter: NumberPickerAdapter(data: [
                  NumberPickerColumn(begin: 1, end: 10, initValue: splashEntity.splashTime),
                ]),
                delimiter: [PickerDelimiter(child: Container(width: 30.0, alignment: Alignment.center, child: Text("秒")))],
                hideHeader: true,
                confirmText: "确定",
                cancelText: "取消",
                title: Text("选择启动时长"),
                onConfirm: (Picker picker, List value) {
                  setState(() {
                    splashEntity.splashTime = picker.getSelectedValues().first as int;
                    splashEntity.toSp();
                  });
                }).showDialog(context);
          },
        ),
        Divider(),
        ListTile(
            title: Text("字体大小"),
            trailing: Text(splashEntity.splashFontSize.toString() + "px", style: TextStyle(color: splashEntity.hasSplash ? Colors.black : Colors.black26)),
            enabled: splashEntity.hasSplash,
            onTap: () {
              Picker(
                  adapter: NumberPickerAdapter(data: [
                    NumberPickerColumn(begin: 6, end: 40, initValue: splashEntity.splashFontSize),
                  ]),
                  delimiter: [PickerDelimiter(child: Container(width: 30.0, alignment: Alignment.center, child: Text("像素")))],
                  hideHeader: true,
                  confirmText: "确定",
                  cancelText: "取消",
                  title: Text("选择字体大小"),
                  onConfirm: (Picker picker, List value) {
                    setState(() {
                      splashEntity.splashFontSize = picker.getSelectedValues().first as int;
                      splashEntity.toSp();
                    });
                  }).showDialog(context);
            }),
        Divider(),
        ListTile(
            title: Text("启动文字"),
            subtitle: Text(splashEntity.splashString),
            enabled: splashEntity.hasSplash,
            trailing: GestureDetector(
                child: Icon(Icons.help),
                onTap: () {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("帮助"),
                          content: Text("编辑文档时，请注意文字不可以过长，否则不能够显示"),
                        );
                      });
                }),
            onTap: () => routePush(SplashStringPage()).then((value) => updatePage()))
      ]),
    );
  }
}
