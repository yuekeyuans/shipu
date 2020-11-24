import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';

class ReadingSettingsEntity {
  ///放大大小
  double baseFont = 1.0;

  ///背景颜色
  Color backGroundColor = Colors.white;
  ////////////////tts 设置
  ///速度
  double speechRate = 1.0;

  ///音量
  double volumn = 1.0;

  ///音调
  double pitch = 1.0;

  /// 循环播放
  bool repeatPlay = false;

  ///悬浮播放按钮
  bool floatPlayButton = false;

  ///主页播放按钮
  bool mainPagePlayButton = false;

  /// 显示注解
  bool showFootNote = true;

  /// 显示纲目
  bool showOutline = true;

  ReadingSettingsEntity.fromSp() {
    baseFont = SpUtil.getDouble("DakaSettingsEntity_baseFont", defValue: 1.0);
    speechRate = SpUtil.getDouble("DakaSettingsEntity_speechRate", defValue: 0.5);
    volumn = SpUtil.getDouble("DakaSettingsEntity_volumn", defValue: 1.0);
    pitch = SpUtil.getDouble("DakaSettingsEntity_pitch", defValue: 1.0);
    showFootNote = SpUtil.getBool("DakaSettingsEntity_showFootNote", defValue: true);
    showOutline = SpUtil.getBool("DakaSettingsEntity_showOutline", defValue: true);
    repeatPlay = SpUtil.getBool("DakaSettingsEntity_repeatPlay", defValue: false);
    floatPlayButton = SpUtil.getBool("DakaSettingsEntity_floatPlayButton", defValue: false);
    mainPagePlayButton = SpUtil.getBool("DakaSettingsEntity_mainPagePlayButton", defValue: false);
  }

  toSp() {
    SpUtil.putDouble("DakaSettingsEntity_baseFont", baseFont);
    SpUtil.putDouble("DakaSettingsEntity_speechRate", speechRate);
    SpUtil.putDouble("DakaSettingsEntity_volumn", volumn);
    SpUtil.putDouble("DakaSettingsEntity_pitch", pitch);
    SpUtil.putBool("DakaSettingsEntity_showFootNote", showFootNote);
    SpUtil.putBool("DakaSettingsEntity_showOutline", showOutline);
    SpUtil.putBool("DakaSettingsEntity_repeatPlay", repeatPlay);
    SpUtil.putBool("DakaSettingsEntity_floatPlayButton", floatPlayButton);
    SpUtil.putBool("DakaSettingsEntity_mainPagePlayButton", mainPagePlayButton);
  }
}
