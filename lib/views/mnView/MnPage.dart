import 'package:flutter/material.dart';

class MnPage extends StatefulWidget {
  @override
  _MnPageState createState() => _MnPageState();
}

class _MnPageState extends State<MnPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("晨兴")),
      body: createBody(),
    );
  }

  Widget createBody() {
    return Text("hello world");
  }
}
