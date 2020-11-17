import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class ReadingSettingsEntity {
  //放大大小
  double baseFont = 1.0;
  //背景颜色
  Color backGroundColor = Colors.white;
  ////////////////tts 设置
  //速度
  double speechRate = 1.0;
  //音量
  double volumn = 1.0;
  //音调
  double pitch = 1.0;

  ReadingSettingsEntity.fromSp() {
    baseFont = SpUtil.getDouble("DakaSettingsEntity_baseFont", defValue: 1.0);
    speechRate = SpUtil.getDouble("DakaSettingsEntity_speechRate", defValue: 0.5);
    volumn = SpUtil.getDouble("DakaSettingsEntity_volumn", defValue: 1.0);
    pitch = SpUtil.getDouble("DakaSettingsEntity_pitch", defValue: 1.0);
  }

  toSp() {
    SpUtil.putDouble("DakaSettingsEntity_baseFont", baseFont);
    SpUtil.putDouble("DakaSettingsEntity_speechRate", speechRate);
    SpUtil.putDouble("DakaSettingsEntity_volumn", volumn);
    SpUtil.putDouble("DakaSettingsEntity_pitch", pitch);
  }
}
