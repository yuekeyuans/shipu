import "package:flutter/material.dart";

class ReciteBiblePage extends StatefulWidget {
  @override
  _ReciteBiblePageState createState() => _ReciteBiblePageState();
}

class _ReciteBiblePageState extends State<ReciteBiblePage> {
  DateTime date;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
  }

  bool get isCurrentDate {
    var curDate = DateTime.now();
    if (curDate.year == curDate.year &&
        curDate.month == date.month &&
        curDate.day == date.day) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("背经"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10),
            child:
                isCurrentDate ? Icon(Icons.date_range) : Icon(Icons.av_timer),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Card(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                Text(
                  "约翰福音 6:68",
                  textAlign: TextAlign.left,
                ),
                Divider(),
                Text(
                  "西门彼得对曰、主有永生之道、吾谁与归、",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 25),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
