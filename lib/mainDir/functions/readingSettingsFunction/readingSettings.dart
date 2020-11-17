import 'package:da_ka/mainDir/functions/readingSettingsFunction/readingSettingsEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nav_router/nav_router.dart';
import 'package:settings_ui/settings_ui.dart';

class ReadingSettings extends StatefulWidget {
  final bool showFontSize;
  final bool showSpeechControl;

  ReadingSettings(this.showFontSize, {this.showSpeechControl = false});

  @override
  _ReadingSettingsState createState() => _ReadingSettingsState();
}

class _ReadingSettingsState extends State<ReadingSettings> {
  FlutterTts flutterTts;

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  //设置字体大小
  fontSizeDialog() {
    var entity = ReadingSettingsEntity.fromSp();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setSpeechRateState) {
            return AlertDialog(
                title: Text("字体大小"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        pop();
                        setState(() {});
                      },
                      child: Text("确定"))
                ],
                content: Wrap(children: <Widget>[
                  Text("设置字体大小倍数为: ${(ReadingSettingsEntity.fromSp().baseFont * 100).toInt()}%", textScaleFactor: ReadingSettingsEntity.fromSp().baseFont),
                  Slider(
                      value: ReadingSettingsEntity.fromSp().baseFont,
                      max: 3.5,
                      min: 0.5,
                      divisions: 300,
                      onChanged: (v) {
                        setSpeechRateState(() {
                          entity.baseFont = v;
                          entity.toSp();
                        });
                      })
                ]));
          });
        });
  }

  //设置声音速度
  speedRate() async {
    var entity = ReadingSettingsEntity.fromSp();
    var rateRange = await flutterTts.getSpeechRateValidRange;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setSpeechRateState) {
            return AlertDialog(
                title: Text("播放速度"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        pop();
                        setState(() {});
                      },
                      child: Text("确定"))
                ],
                content: Wrap(children: <Widget>[
                  Text("设置播放速度为: ${(ReadingSettingsEntity.fromSp().speechRate * 100).toInt()}%"),
                  Slider(
                      value: ReadingSettingsEntity.fromSp().speechRate,
                      max: rateRange.max,
                      min: rateRange.min,
                      divisions: 300,
                      onChanged: (v) {
                        setSpeechRateState(() {
                          entity.speechRate = v;
                          entity.toSp();
                        });
                      })
                ]));
          });
        });
  }

  //设置音量
  volumn() async {
    var entity = ReadingSettingsEntity.fromSp();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setSpeechRateState) {
            return AlertDialog(
                title: Text("音量"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        pop();
                        setState(() {});
                      },
                      child: Text("确定"))
                ],
                content: Wrap(children: <Widget>[
                  Text("设置音量为: ${(ReadingSettingsEntity.fromSp().volumn * 100).toInt()}%"),
                  Slider(
                      value: ReadingSettingsEntity.fromSp().volumn,
                      max: 1.0,
                      min: 0.0,
                      divisions: 100,
                      onChanged: (v) {
                        setSpeechRateState(() {
                          entity.volumn = v;
                          entity.toSp();
                        });
                      })
                ]));
          });
        });
  }

  //设置音调
  pitch() {
    var entity = ReadingSettingsEntity.fromSp();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setSpeechRateState) {
            return AlertDialog(
                title: Text("音调"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        pop();
                        setState(() {});
                      },
                      child: Text("确定"))
                ],
                content: Wrap(children: <Widget>[
                  Text("设置音调为: ${(ReadingSettingsEntity.fromSp().pitch * 100).toInt()}%"),
                  Slider(
                      value: ReadingSettingsEntity.fromSp().pitch,
                      max: 2.0,
                      min: 0.5,
                      divisions: 150,
                      onChanged: (v) {
                        setSpeechRateState(() {
                          entity.pitch = v;
                          entity.toSp();
                        });
                      })
                ]));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    var settingsSection = <SettingsSection>[];
    //字体大小
    if (widget.showFontSize) {
      settingsSection.add(SettingsSection(title: "文字设置", tiles: [
        SettingsTile(
          title: "放大倍数",
          trailing: Text("${(ReadingSettingsEntity.fromSp().baseFont * 100).toInt()}%"),
          onTap: fontSizeDialog,
        )
      ]));
      //语音设置
      if (widget.showSpeechControl) {
        settingsSection.add(SettingsSection(
          title: "语音设置",
          tiles: [
            SettingsTile(title: "音量", trailing: Text("${(ReadingSettingsEntity.fromSp().volumn * 100).toInt()}%"), onTap: volumn),
            SettingsTile(title: "速度", trailing: Text("${(ReadingSettingsEntity.fromSp().speechRate * 100).toInt()}%"), onTap: speedRate),
            SettingsTile(title: "音调", trailing: Text("${(ReadingSettingsEntity.fromSp().pitch * 100).toInt()}%"), onTap: pitch),
          ],
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("设置")),
      body: SettingsList(sections: settingsSection),
    );
  }
}