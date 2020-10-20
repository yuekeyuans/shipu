import 'package:flustars/flustars.dart';

class ReciteBibleEntity {
  bool isOn = false;
  String currentBook;
  int verseOfDay = 1;
  String delayMode = "";
  DateTime startDate;
  bool isMultiLanguange = false;
  int fontSize = 16;

  ReciteBibleEntity.instance();

  ReciteBibleEntity.fromSp() {
    isOn = SpUtil.getBool("ReciteBibleEntity_isOn");
    currentBook = SpUtil.getString("ReciteBibleEntity_currentBook");
    verseOfDay = SpUtil.getInt("ReciteBibleEntity_verseOfDay");
    delayMode = SpUtil.getString("ReciteBibleEntity_delayMode");
    isMultiLanguange = SpUtil.getBool("ReciteBibleEntity_isMultiLanguange");
    fontSize = SpUtil.getInt("ReciteBibleEntity_fontSize");
    startDate = DateTime.parse(SpUtil.getString("ReciteBibleEntity_startDate"));
  }

  void toSp() {
    SpUtil.putBool("ReciteBibleEntity_isOn", isOn);
    SpUtil.putString("ReciteBibleEntity_currentBook", currentBook);
    SpUtil.putInt("ReciteBibleEntity_verseOfDay", verseOfDay);
    SpUtil.putInt("ReciteBibleEntity_fontSize", fontSize);
    SpUtil.putString("ReciteBibleEntity_delayMode", delayMode);
    SpUtil.putBool("ReciteBibleEntity_isMultiLanguange", isMultiLanguange);
    SpUtil.putString(
        "ReciteBibleEntity_startDate",
        startDate == null
            ? DateTime.now().toIso8601String()
            : startDate.toIso8601String());
  }
}
