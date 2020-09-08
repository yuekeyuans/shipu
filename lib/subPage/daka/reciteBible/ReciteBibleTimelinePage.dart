import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ReciteBibleTimelinePage extends StatefulWidget {
  @override
  _ReciteBibleTimelinePageState createState() =>
      _ReciteBibleTimelinePageState();
}

class _ReciteBibleTimelinePageState extends State<ReciteBibleTimelinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("背经时间线")),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TimelineTile(
            alignment: TimelineAlign.manual,
            lineX: 0.1,
            isFirst: true,
            indicatorStyle: const IndicatorStyle(
              width: 20,
              color: Colors.purple,
            ),
            topLineStyle: const LineStyle(
              color: Colors.purple,
              width: 6,
            ),
          ),
        ],
      ),
    );
  }
}
