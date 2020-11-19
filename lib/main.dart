import 'dart:io';
import 'dart:isolate';
import 'package:da_ka/db/bible/bibleDb.dart';
import 'package:da_ka/db/mainDb/sqliteDb.dart';
import 'package:da_ka/db/lifestudyDb/LifeStudyDb.dart';
import 'package:da_ka/global.dart';
import 'package:da_ka/main_navigator_page.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_splashscreen/simple_splashscreen.dart';
import 'package:nav_router/nav_router.dart';
import 'package:sp_util/sp_util.dart';
import 'package:wakelock/wakelock.dart';

import 'db/neeDb/NeeDb.dart';
import 'mainDir/functions/dakaFunction/recitebible/daka_recite_bible_entity.dart';
import 'mainDir/functions/splashFunction/SplashScreen.dart';
import 'mainDir/functions/splashFunction/splahEntity.dart';
import 'mainDir/functions/utilsFunction/UtilFunction.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  await createPath();
  await initVal().then((value) {
    print(SpUtil.getString("MAIN_PATH"));
    copyPf0File();
  });
  initDb();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var homePage = MainNavigator();
    var splashEntity = SplashEntity.fromSp();

    return OKToast(
        position: ToastPosition.bottom,
        duration: Duration(seconds: 2),
        child: DynamicTheme(
            defaultBrightness: Brightness.light,
            data: (_brightness) => ThemeData(
                  backgroundColor: _brightness == Brightness.light ? backgroundGray : Colors.black,
                  brightness: _brightness,
                  primaryColor: _brightness == Brightness.light ? Colors.white : null,
                  accentColor: Colors.cyan[600],
                  fontFamily: 'Montserrat',
                  appBarTheme: AppBarTheme(brightness: _brightness),
                ),
            themedWidgetBuilder: (context, theme) {
              return MaterialApp(
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    SfGlobalLocalizations.delegate,
                  ],
                  supportedLocales: [
                    const Locale('zh'),
                  ],
                  locale: const Locale('zh'),
                  title: '食谱',
                  theme: theme,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: navGK,
                  home: splashEntity.hasSplash
                      ? Simple_splashscreen(
                          context: context,
                          gotoWidget: homePage,
                          splashscreenWidget: SplashScreen(),
                          timerInSeconds: splashEntity.splashTime,
                        )
                      : homePage);
            }));
  }
}

Future<void> initialize() async {
  await [
    Permission.storage,
    Permission.camera,
  ].request();

  await Wakelock.enable();
}

Future<void> createPath() async {
  await SpUtil.getInstance();
  var basePath = (await getExternalStorageDirectory()).parent.parent.parent.parent.path;
  Map<String, String> dirNames = {
    "GLOBAL_PATH": basePath,
    "MAIN_PATH": "$basePath/zhuhuifu",
    "TEMP_PATH": "$basePath/zhuhuifu/temp",
    "ENCRYPTION_PATH": "$basePath/zhuhuifu/encryption",
    "DECRYPTION_PATH": "$basePath/zhuhuifu/decryption",
    "DB_PATH": "$basePath/zhuhuifu/database",
    "ISILO_PDB_PATH": "$basePath/documents/iSilo",
    "ISILO_PATH": "$basePath/documents/iSilo/Settings",
    "ISILO_SETTING_PATH": "$basePath/documents/iSilo/Settings/_Reg_",
  };

  for (var key in dirNames.keys) {
    if (!Directory(dirNames[key]).existsSync()) {
      await DirectoryUtil.createDir(dirNames[key]);
    }
    await SpUtil.putString(key, dirNames[key]);
  }
}

Future<void> initVal() async {
  //创建文件夹

  //判断是否定义过变量
  if (!SpUtil.getBool("defined", defValue: false) || SpUtil.getString("MAIN_PATH", defValue: "") == "") {
    await SpUtil.putBool("defined", true);
    //文件是否加密发送
    await SpUtil.putBool("Encryption", false);
    //splash
    await SplashEntity().toSp();
    //背经
    ReciteBibleEntity.instance().toSp();
    //扫描文件显示已添加文件
    await SpUtil.putBool("scanFile_show_add", true);
  }
}

/// 文件拷贝初始化异步执行，避免阻塞文件运行
Future<void> initDb() async {
  await MainDb().db;
  await BibleDb().db;
  await LifeStudyDb().db;
  await NeeDb().db;
}

// the entry point for the isolate
echo(SendPort sendPort) async {
  // Open the ReceivePort for incoming messages.
  var port = ReceivePort();

  // Notify any other isolates what port this isolate listens to.
  sendPort.send(port.sendPort);

  await for (var msg in port) {
    var data = msg[0];
    SendPort replyTo = msg[1] as SendPort;
    replyTo.send(data);
    if (data == "bar") port.close();
  }
}

/// sends a message on a port, receives the response,
/// and returns the message
Future sendReceive(SendPort port, msg) {
  ReceivePort response = ReceivePort();
  port.send([msg, response.sendPort]);
  return response.first;
}

// pf0 文件拷贝，这个文件设置isilo 文件位置
// 这是isilo 的文件夹位置，每次使用都拷贝一次
Future<void> copyPf0File() async {
  var filename = "pf0";
  String dir = SpUtil.getString("ISILO_SETTING_PATH");
  var path = '$dir/$filename';
  if (File(path).existsSync()) {
    File(path).deleteSync();
  }
  var bytes = await rootBundle.load("assets/pf0");
  UtilFunction.copyFile(bytes, path);
}
