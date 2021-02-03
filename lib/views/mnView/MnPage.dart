import 'package:da_ka/global.dart';
import 'package:flutter/material.dart';
import 'package:da_ka/db/mn/mnDb.dart';
import 'package:nav_router/nav_router.dart';
import 'mnFileManagerPage.dart';

class MnPage extends StatefulWidget {
  @override
  _MnPageState createState() => _MnPageState();
}

class _MnPageState extends State<MnPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(APPBAR_HEIGHT),
        child: AppBar(
          title: Text("晨兴"),
          actions: [],
        ),
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    if (!MnDb.exist()) {
      return manageFileWidget();
    }
    return Text("hello world");
  }

  // 没有文件被加载，加载当前文件类型
  Widget manageFileWidget() {
    return Container(
        color: Colors.grey,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Center(
                child: Column(children: [
              GestureDetector(
                child: Text("文件不存在，点击查找",
                    style: TextStyle(color: Color(0xFFB61D1D))),
                onTap: () => routePush(MnFileManagerPage()),
              ),
            ])),
          ],
        ));
  }
}
