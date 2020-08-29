import 'package:da_ka/global.dart';
import "package:flutter/material.dart";
import 'main_navigator_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String value = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(title: Text(widget.title), actions: <Widget>[
            PopupMenuButton(
                onSelected: (String selectValue) {
                  setState(() {
                    value = selectValue;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      new PopupMenuItem(value: "1", child: new Text("查看日期")),
                      new PopupMenuItem(value: "2", child: new Text("查看记录"))
                    ],
                icon: Icon(Icons.more_vert),
                offset: Offset(0, 100))
          ]),
          preferredSize: Size.fromHeight(APPBAR_HEIGHT)),
      body: MainNavigator(),
      drawer: Drawer(
        child: ListView(children: <Widget>[Text("hello world")]),
      ),
    );
  }
}
