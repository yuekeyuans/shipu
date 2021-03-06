import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/splashFunction/splahEntity.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import 'SplashScreen.dart';

/// 用于设置使用的splashString
class SplashStringPage extends StatefulWidget {
  @override
  _SplashStringPageState createState() => _SplashStringPageState();
}

class _SplashStringPageState extends State<SplashStringPage> {
  SplashEntity entity = SplashEntity.fromSp();

  @override
  void initState() {
    super.initState();
    entity = SplashEntity.fromSp();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          pop("finished");
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text("启动页文字"),
              actions: <Widget>[GestureDetector(child: Icon(Icons.add), onTap: () => createString()), Padding(padding: EdgeInsets.only(right: 10))],
            ),
            body: Container(
              color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    var str = entity.splashStrings[index];
                    return ListTile(
                        title: Text(
                          str,
                          textAlign: TextAlign.center,
                        ),
                        onTap: () => setState(
                              () {
                                entity.splashString = str;
                                entity.toSp();
                              },
                            ),
                        onLongPress: entity.splashStrings.length > 1 ? () => deleteOptions(index) : null,
                        trailing: entity.splashString == str ? CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.check, color: Colors.redAccent)) : null);
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: entity.splashStrings.length),
            )));
  }

  void deleteOptions(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("确认"),
            content: Text("确认删除该条目?"),
            actions: <Widget>[
              FlatButton(onPressed: () => pop("deleted"), child: Text("否")),
              FlatButton(
                  onPressed: () {
                    var isSelected = entity.splashString == entity.splashStrings[index];
                    if (isSelected) {
                      setState(() {
                        entity.splashStrings.remove(entity.splashString);
                        entity.splashString = entity.splashStrings.first;
                      });
                    } else {
                      setState(() => entity.splashStrings.remove(entity.splashStrings[index]));
                    }
                    pop("accept");
                  },
                  child: Text("是"))
            ],
          );
        });
  }

  void createString() {
    String tempContent = "";
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("创建启动页文字"),
            content: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 10, //不限制行数
                onChanged: (v) => tempContent = v),
            actions: <Widget>[
              FlatButton(child: Text("取消"), onPressed: () => Navigator.pop(context, "cancel")),
              FlatButton(child: Text("预览"), onPressed: () => routePush(SplashScreen(content: tempContent))),
              FlatButton(
                  child: Text("确定"),
                  onPressed: () {
                    setState(() {
                      entity.addString(tempContent);
                      entity.splashString = tempContent;
                      entity.toSp();
                    });
                    Navigator.pop(context, "yes");
                  }),
            ],
          );
        });
  }
}
