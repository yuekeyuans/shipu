import 'package:da_ka/db/bibleDb.dart';
import 'package:da_ka/db/sqliteDb.dart';
import 'package:da_ka/subPage/functions/dakaFunction/daka_recite_bible_entity.dart';
import 'package:da_ka/subPage/functions/splashFunction/splahEntity.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_splashscreen/simple_splashscreen.dart';
import 'HomePage.dart';
import 'subPage/functions/splashFunction/SplashScreen.dart';
import 'package:nav_router/nav_router.dart';
import 'package:sp_util/sp_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initVal();
  await initDb();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final splashEntity = SplashEntity.fromSp();

  @override
  Widget build(BuildContext context) {
    var homePage = MyHomePage(title: "学习");
    return MaterialApp(
      title: '打卡',
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Colors.white,
        accentColor: Colors.cyan[600],
        fontFamily: 'Montserrat',
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: navGK,
      home: splashEntity.hasSplash
          ? Simple_splashscreen(
              context: context,
              gotoWidget: homePage,
              splashscreenWidget: SplashScreen(),
              timerInSeconds: splashEntity.splashTime)
          : homePage,
    );
  }
}

initVal() async {
  ///检查是否有权限
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.camera,
  ].request();
  print(statuses[Permission.storage]);

  await SpUtil.getInstance();
  //判断是否定义过变量
  if (SpUtil.getBool("defined", defValue: false)) {
    return;
  }

  SpUtil.putBool("defined", true);

  var basePath =
      (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
  DirectoryUtil.createDir(basePath);
  SpUtil.putString("GLOBAL_PATH", basePath);

  DirectoryUtil.createDir(basePath + "/zhuhuifu");
  SpUtil.putString("MAIN_PATH", basePath + "/zhuhuifu");

  DirectoryUtil.createDir(basePath + "/zhuhuifu/temp");
  SpUtil.putString("TEMP_PATH", basePath + "/zhuhuifu/temp");

  DirectoryUtil.createDir("$basePath/zhuhuifu/encryption");
  SpUtil.putString("ENCRYPTION_PATH", "$basePath/zhuhuifu/encryption");

  DirectoryUtil.createDir("$basePath/zhuhuifu/decryption");
  SpUtil.putString("DECRYPTION_PATH", "$basePath/zhuhuifu/decryption");

  DirectoryUtil.createDir(basePath + "/zhuhuifu/database");
  SpUtil.putString("DB_PATH", basePath + "/zhuhuifu/database");

  DirectoryUtil.createDir(basePath + "/documents/iSilo/Settings");
  SpUtil.putString("ISILO_PATH", basePath + "/documents/iSilo/Settings");

  //文件是否加密发送
  SpUtil.putBool("Encryption", false);

  //splash
  SplashEntity().setSp();

  //背经
  ReciteBibleEntity.instance().toSp();
}

Future<void> initDb() async {
  await DatabaseHelper().db;
  await BibleDatabaseHelper().db;
}
