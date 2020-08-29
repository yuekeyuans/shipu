import 'package:da_ka/subPage/checkInPage.dart';
import 'package:da_ka/subPage/contentPage.dart';
import 'package:da_ka/subPage/settingPage.dart';
import 'package:flutter/material.dart';

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  List<Widget> pages = List<Widget>();
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
          BottomNavigationBarItem(
              icon: Icon(Icons.list), title: new Text('内容')),
          BottomNavigationBarItem(
              icon: Icon(Icons.check), title: new Text('打卡')),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), title: new Text('功能')),
        ],
        currentIndex: _currentIndex,
        onTap: (int i) {
          setState(() {
            _currentIndex = i;
          });
        },
        selectedItemColor: Colors.red,
        showUnselectedLabels: true,
      ),
    );
  }
}
