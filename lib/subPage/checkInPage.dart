import 'package:flutter/material.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<String> items = new List<String>();

  @override
  void initState() {
    super.initState();
    items
      ..add("背经")
      ..add("新约")
      ..add("旧约")
      ..add("生命读经")
      ..add("每月一书")
      ..add("每日一歌");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
        itemBuilder: (context, index) {
          return ListTile(title: Text(items[index]));
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: 1,
          );
        },
        itemCount: items.length,
      ),
    );
  }
}
