import 'package:da_ka/global.dart';
import 'package:da_ka/mainDir/contentPage/contentPageEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:settings_ui/settings_ui.dart';

class ContentManageFunctionPage extends StatefulWidget {
  @override
  _ContentManageFunctionPageState createState() => _ContentManageFunctionPageState();
}

class _ContentManageFunctionPageState extends State<ContentManageFunctionPage> {
  var viewModeType = ["列表", "分类"];

  void changeViewMode() {
    Picker(
        adapter: PickerDataAdapter<String>(pickerdata: viewModeType),
        hideHeader: true,
        confirmText: "确定",
        cancelText: "取消",
        title: Text("选择显示方式"),
        onConfirm: (Picker picker, List value) {
          var selected = picker.getSelectedValues().first as String;
          var entity = ContentPageEntity.fromSp();
          entity.listType = ContentPageEntityType.values[viewModeType.indexOf(selected)];
          entity.toSp();
          setState(() {});
        }).showDialog(context);
  }

  List<SettingsSection> getChildren() {
    var lst = <SettingsSection>[
      SettingsSection(title: "页面显示方式", tiles: [
        SettingsTile(
          title: "开启背经功能",
          subtitle: viewModeType[ContentPageEntity.fromSp().listType.index],
          onTap: changeViewMode,
        )
      ])
    ];
    return lst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: PreferredSize(child: AppBar(title: Text("设置")), preferredSize: Size.fromHeight(APPBAR_HEIGHT)), body: SettingsList(sections: getChildren()));
  }
}
