import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/functions/apkInstall/apkInstallFunctionPage.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';
import 'package:settings_ui/settings_ui.dart';

import 'contentManageFunction/contentManageFunctionPage.dart';
import 'dakaFunction/dakaFunctionPage.dart';
import 'encriptionFunction/encriptionFunctionPage.dart';
import 'scanFileFunction/scanFile.dart';
import 'splashFunction/splashFunction.dart';
import 'storageFunction/storageFunctionPage.dart';

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
              title: "文件列表管理",
              leading: Icon(Icons.list),
              onTap: () => routePush(ContentManageFunctionPage()),
            ),
            SettingsTile(
              title: "存储管理",
              leading: Icon(Icons.storage),
              onTap: () => routePush(StorageFunctionPage()),
            ),
          ],
        ),
        SettingsSection(
          title: "其他软件管理",
          tiles: [
            SettingsTile(
              title: "软件管理",
              leading: Icon(Icons.android),
              onTap: () => routePush(ApkFunctionInstallPage()),
            ),
          ],
        )
      ],
    );
  }
}
