import 'package:da_ka/global.dart';
import 'package:da_ka/views/bibleView/ynybJyPage.dart';
import 'package:da_ka/views/bibleView/ynybxyPage.dart';
import 'package:da_ka/views/smdj/lifeStudyPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nav_router/nav_router.dart';
import 'package:settings_ui/settings_ui.dart';

class DailyPage extends StatefulWidget {
  @override
  _DailyPageState createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: AppBar(
            title: Text("日常操练"),
          ),
          preferredSize: Size.fromHeight(APPBAR_HEIGHT)),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: "一年一遍",
            tiles: [
              SettingsTile(
                title: "新约",
                leading: SvgPicture.asset("assets/icon/book_new.svg", width: 32, height: 32, color: Theme.of(context).disabledColor),
                onTap: () => routePush(YnybXyPage()),
              ),
              SettingsTile(
                title: "旧约",
                leading: SvgPicture.asset("assets/icon/book_old.svg", width: 32, height: 32, color: Theme.of(context).disabledColor),
                onTap: () => routePush(YnybJyPage()),
              ),
              SettingsTile(
                title: "生命读经",
                leading: SvgPicture.asset("assets/icon/life_reading.svg", width: 32, height: 32, color: Theme.of(context).disabledColor),
                onTap: () => routePush(LifeStudyPage()),
              ),
            ],
          )
        ],
      ),
    );
  }
}
