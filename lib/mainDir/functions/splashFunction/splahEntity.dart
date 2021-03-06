import "package:sp_util/sp_util.dart";

class SplashEntity {
  int splashTime = 4;
  int splashFontSize = 26;
  bool hasSplash = true;
  String splashString = "歌罗西书 3:16\n当用各样的智慧，\n让基督的话丰丰富富的住在你们里面，\n用诗章、颂辞、灵歌，\n彼此教导，互相劝戒，\n心被恩感歌颂神；";

  var splashStrings = ["歌罗西书 3:16\n当用各样的智慧，\n让基督的话丰丰富富的住在你们里面，\n用诗章、颂辞、灵歌，\n彼此教导，互相劝戒，\n心被恩感歌颂神；", "约翰福音 6:68\n西门彼得对曰、\n主有永生之道、\n吾谁与归、"];

  SplashEntity();

  SplashEntity.fromSp() {
    hasSplash = SpUtil.getBool("hasSplash", defValue: false);
    splashTime = SpUtil.getInt("splashTime", defValue: 10);
    splashString = SpUtil.getString("splashString", defValue: "欢迎使用");
    splashFontSize = SpUtil.getInt("splashFontSize", defValue: 20);
    splashStrings = SpUtil.getStringList("splashStrings");
  }

  Future<void> toSp() async {
    await SpUtil.putBool("hasSplash", hasSplash);
    await SpUtil.putInt("splashTime", splashTime);
    await SpUtil.putString("splashString", splashString);
    await SpUtil.putInt("splashFontSize", splashFontSize);
    await SpUtil.putStringList("splashStrings", splashStrings);
  }

  void addString(String str) => splashStrings.add(str);
}
