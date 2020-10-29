import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/apkInstall/apkClockInFunctionPage.dart';
import 'package:da_ka/mainDir/functions/apkInstall/apkIsiloFunctionPage.dart';
import 'package:da_ka/mainDir/functions/apkInstall/apkKuaichuanFunctionPage.dart';
import 'package:da_ka/mainDir/functions/descriptionFunction/descriptionFunction.dart';
import 'package:da_ka/views/daka/dakaSettings/DakaSettings.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nav_router/nav_router.dart';
import 'package:settings_ui/settings_ui.dart';

import 'scanFileFunction/scanFile.dart';
import 'splashFunction/splashFunction.dart';
import 'storageFunction/storageFunctionPage.dart';
import 'package:da_ka/views/nee/neePage.dart';

class FunctionPage extends StatefulWidget {
  @override
  _FunctionPageState createState() => _FunctionPageState();
}

class _FunctionPageState extends State<FunctionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(child: AppBar(title: Text("功能")), preferredSize: Size.fromHeight(APPBAR_HEIGHT)),
      body: buildSettingList(context),
    );
  }

  Widget buildSettingList(BuildContext context) {
    return SettingsList(
      sections: [
        SettingsSection(
          title: "扫描",
          tiles: [
            SettingsTile(
              title: "扫描文件夹",
              leading: Icon(Icons.update),
              onTap: () => routePush(ScanFilesPage()),
            ),
          ],
        ),
        SettingsSection(
          title: "设置",
          tiles: [
            SettingsTile.switchTile(
              title: "黑暗模式",
              leading: Icon(Icons.chrome_reader_mode),
              switchValue: Theme.of(context).brightness == Brightness.dark,
              onToggle: (bool mode) {
                DynamicTheme.of(context).setBrightness(Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark);
                setState(() {});
              },
            ),
            SettingsTile.switchTile(
              title: "文件加密",
              leading: Icon(Icons.enhanced_encryption),
              onToggle: (bool value) {
                SpUtil.putBool("Encryption", value);
                setState(() {});
              },
              switchValue: SpUtil.getBool("Encryption"),
            ),
            SettingsTile(
              title: "启动页",
              leading: Icon(Icons.screen_share),
              onTap: () => routePush(SplashFunctionPage()),
            ),
            SettingsTile(
              title: "存储管理",
              leading: Icon(Icons.storage),
              onTap: () => routePush(StorageFunctionPage()),
            ),
            SettingsTile(
              title: "阅读设置",
              leading: Icon(Icons.remove_red_eye),
              onTap: () => routePush(DakaSettings()),
            ),
          ],
        ),
        SettingsSection(
          title: "其他软件管理",
          tiles: [
            SettingsTile(title: "isilo", leading: Image.asset("assets/icon/isilo.png", scale: 1.5), onTap: () => routePush(ApkIsiloFunctionPage())),
            SettingsTile(title: "快传", leading: SvgPicture.asset("assets/icon/kuaichuan.svg", width: 32, height: 32, color: Colors.green), onTap: () => routePush(ApkKuaichuanFunctionPage())),
            SettingsTile(title: "clock in", leading: Image.asset("assets/icon/icon.png", scale: 8), onTap: () => routePush(ApkClockInFunctionPage())),
          ],
        ),
        SettingsSection(
          title: "说明",
          tiles: [
            SettingsTile(
              title: "信息",
              leading: Icon(Icons.link),
              onTap: () => routePush(DescriptionFunction()),
            ),
          ],
        ),
        SettingsSection(
          title: "测试",
          tiles: [
            SettingsTile(
              title: "nee",
              leading: Icon(Icons.link),
              onTap: () => routePush(NeePage(1, 1)),
            ),
          ],
        ),
      ],
    );
  }
}
