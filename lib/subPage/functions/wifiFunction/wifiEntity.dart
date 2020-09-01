class WifiDirectObject {
  static const String TYPE_STRING = "String";
  static const String TYPE_FILE = "File";

  String name;
  String type;
  List<int> content;

  WifiDirectObject.fromObj(List<int> obj) {
    int cur = 0;
    var nameLen = obj[cur++];
    name = String.fromCharCodes(obj, cur, cur = cur + nameLen);
    var typeLen = obj[cur++];
    type = String.fromCharCodes(obj.getRange(cur, cur = cur + typeLen));
    content = obj.getRange(cur, obj.length);
  }

  List<int> toObj() {
    List<int> list = [];
    var nameUint = name.codeUnits;
    list.add(nameUint.length);
    list.addAll(nameUint);

    var typeUint = type.codeUnits;
    list.add(typeUint.length);
    list.addAll(typeUint);

    list.add(content.length);
    list.addAll(content);

    return list;
  }

  WifiDirectObject(this.name, this.type, this.content);
}
