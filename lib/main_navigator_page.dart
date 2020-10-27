import 'package:da_ka/mainDir/dailyWork/functions.dart';
import 'package:da_ka/mainDir/contentPage/contentPage.dart';
import 'package:da_ka/mainDir/functions/functionsPage.dart';
import 'package:flutter/material.dart';

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  List<Widget> pages = <Widget>[];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pages..add(ContentPage())..add(CheckInPage())..add(FunctionPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.work), label: '文件'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: '日常'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '功能'),
          ],
          currentIndex: _currentIndex,
          onTap: (int i) => setState(() => _currentIndex = i),
          selectedItemColor: Colors.red,
          showUnselectedLabels: true,
        ));
  }
}
