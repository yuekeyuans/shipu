import 'package:da_ka/subPage/functions/splashFunction/splahEntity.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final content = null;
  SplashScreen({content});
  @override
  _SplashScreenState createState() => _SplashScreenState(content);
}

class _SplashScreenState extends State<SplashScreen> {
  SplashEntity splashEntity = SplashEntity.fromSp();
  String content;
  _SplashScreenState(content);

  @override
  void initState() {
    super.initState();
    content = content ?? splashEntity.splashString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(5),
      child: Align(
        alignment: Alignment.center,
        child: Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: splashEntity.splashFontSize.toDouble(), fontFamily: 'kaiti')),
      ),
    ));
  }
}
