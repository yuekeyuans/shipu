import 'package:flustars/flustars.dart';

class ContentPageEntity {
  ContentPageEntity();
  ContentPageEntityType listType = ContentPageEntityType.type;

  ContentPageEntity.fromSp() {
    listType = ContentPageEntityType.values[SpUtil.getInt("ContentPageEntity_listType")];
  }

  Future<bool> toSp() async => await SpUtil.putInt("ContentPageEntity_listType", listType.index);
}

enum ContentPageEntityType {
  //直接排列
  list,
  //按照类型排列
  type,
}
