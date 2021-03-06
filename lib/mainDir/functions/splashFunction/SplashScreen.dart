import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/splashFunction/splahEntity.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String content;
  SplashScreen({this.content});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashEntity splashEntity = SplashEntity.fromSp();
  String content;
  _SplashScreenState({this.content});

  @override
  void initState() {
    super.initState();
    content = widget.content ?? splashEntity.splashString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
      padding: EdgeInsets.all(5),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: splashEntity.splashFontSize.toDouble(), fontFamily: 'kaiti'),
        ),
      ),
    ));
  }
}
