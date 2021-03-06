import 'package:da_ka/mainDir/contentPage/contentPageByTypes.dart';
import 'package:flutter/material.dart';
import 'package:da_ka/global.dart';

class ContentPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(title: Text("文件列表")),
        preferredSize: Size.fromHeight(APPBAR_HEIGHT),
      ),
      body: Container(color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black, child: ContentPageByTypes()),
    );
  }
}
