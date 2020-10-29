import 'package:flutter/material.dart';
import 'package:da_ka/db/neeDb/neeContentTable.dart';

class NeePage extends StatefulWidget {
  final int bookInex;
  final int chapter;
  NeePage(this.bookInex, this.chapter);
  @override
  _NeePageState createState() => _NeePageState();
}

class _NeePageState extends State<NeePage> {
  List<NeeContentTable> mixedList = [];

  String title = "倪文集";

  @override
  void initState() {
    super.initState();
    updateData();
  }

  Future<void> updateData() async {
    mixedList = await NeeContentTable().queryChapter();
    print(mixedList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: createBody(),
    );
  }

  ListView createBody() {
    return ListView.separated(
        itemBuilder: (_, index) {
          return ListTile(title: Text(mixedList[index].content));
        },
        separatorBuilder: (_, index) {
          return Divider(height: .0);
        },
        itemCount: mixedList.length);
  }
}
