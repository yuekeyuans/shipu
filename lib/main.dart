import 'package:da_ka/db/bible/bibleDb.dart';
import 'package:da_ka/db/lifestudyDb/lifestudyTable.dart';
import 'package:da_ka/db/mainDb/sqliteDb.dart';
import 'package:da_ka/db/lifestudyDb/LifeStudyDb.dart';
import 'package:da_ka/mainDir/contentPage/contentPageEntity.dart';
import 'package:da_ka/main_navigator_page.dart';
import 'package:da_ka/subPage/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'package:da_ka/subPage/functions/splashFunction/splahEntity.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_splashscreen/simple_splashscreen.dart';
import 'package:da_ka/subPage/functions/splashFunction/SplashScreen.dart';
import 'package:nav_router/nav_router.dart';
import 'package:sp_util/sp_util.dart';
import 'package:wakelock/wakelock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initVal();
  await initDb();
  await Wakelock.enable();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final splashEntity = SplashEntity.fromSp();

  @override
  Widget build(BuildContext context) {
    var homePage = MainNavigator();
    return OKToast(
        position: ToastPosition.bottom,
        duration: Duration(seconds: 2),
        child: MaterialApp(
          title: '打卡',
          theme: ThemeData(brightness: Brightness.light, primaryColor: Colors.white, accentColor: Colors.cyan[600], fontFamily: 'Montserrat'),
          debugShowCheckedModeBanner: false,
          navigatorKey: navGK,
          home: splashEntity.hasSplash ? Simple_splashscreen(context: context, gotoWidget: homePage, splashscreenWidget: SplashScreen(), timerInSeconds: splashEntity.splashTime) : homePage,
        ));
  }
}

Future<void> initVal() async {
  ///检查是否有权限
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.camera,
  ].request();
  print(statuses[Permission.storage]);
  var basePath = (await getExternalStorageDirectory()).parent.parent.parent.parent.path;

  await SpUtil.getInstance();
  //判断是否定义过变量
  if (!SpUtil.getBool("defined", defValue: false) || SpUtil.getString("MAIN_PATH", defValue: "") == "") {
    await SpUtil.putBool("defined", true);

    await DirectoryUtil.createDir(basePath);
    await SpUtil.putString("GLOBAL_PATH", basePath);
    await DirectoryUtil.createDir(basePath + "/zhuhuifu");
    await SpUtil.putString("MAIN_PATH", basePath + "/zhuhuifu");
    await DirectoryUtil.createDir(basePath + "/zhuhuifu/temp");
    await SpUtil.putString("TEMP_PATH", basePath + "/zhuhuifu/temp");
    await DirectoryUtil.createDir("$basePath/zhuhuifu/encryption");
    await SpUtil.putString("ENCRYPTION_PATH", "$basePath/zhuhuifu/encryption");
    await DirectoryUtil.createDir("$basePath/zhuhuifu/decryption");
    await SpUtil.putString("DECRYPTION_PATH", "$basePath/zhuhuifu/decryption");
    await DirectoryUtil.createDir(basePath + "/zhuhuifu/database");
    await SpUtil.putString("DB_PATH", basePath + "/zhuhuifu/database");
    await DirectoryUtil.createDir(basePath + "/documents/iSilo/Settings");
    await SpUtil.putString("ISILO_PATH", basePath + "/documents/iSilo/Settings");
    //文件是否加密发送
    await SpUtil.putBool("Encryption", false);
    //splash
    SplashEntity().toSp();
    //背经
    ReciteBibleEntity.instance().toSp();
    //主页面展示
    ContentPageEntity().toSp();
  }
}

Future<void> initDb() async {
  await MainDb().db;
  await BibleDb().db;
  await LifeStudyDb().db;
}
