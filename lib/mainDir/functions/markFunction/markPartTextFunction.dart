import 'package:da_ka/db/bible/bibleContentTable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_swatch_picker.dart';

/**
 * 这一个的功能先不实现，有点搞不定，到时机好的时候再搞一下吧。
 */
///对于文本,划线选择
class MarkPartTextFunction extends StatefulWidget {
  final BibleContentTable bible;
  MarkPartTextFunction(this.bible);
  @override
  _MarkPartTextFunctionState createState() => _MarkPartTextFunctionState();
}

class _MarkPartTextFunctionState extends State<MarkPartTextFunction> {
  ///底线颜色
  Color currentColor = Colors.red;

  ///mark标记
  List<int> marked = [];

  @override
  void initState() {
    super.initState();
    marked = List.generate(widget.bible.content.length, (index) => 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑重点"),
        actions: [IconButton(icon: Icon(Icons.check), onPressed: null)],
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    return Column(
      children: [
        createCurrentColor(),
        Expanded(child: createMarkArea()),
      ],
    );
  }

  ///底色配置
  Widget createCurrentColor() {
    var backgroundColor = currentColor == Colors.black ? Colors.white : Colors.black;
    return GestureDetector(
        child: Container(
          child: Row(
            children: [Expanded(child: Text("当前底色,点击更换颜色", textAlign: TextAlign.center, style: TextStyle(color: backgroundColor, fontWeight: FontWeight.bold)))],
          ),
          height: 40,
          color: currentColor,
        ),
        onTap: () => showMaterialSwatchPicker(
              title: "选取文字颜色",
              context: context,
              selectedColor: Colors.black,
              onChanged: (color) => setState(() => currentColor = color),
            ));
  }

  Widget createMarkArea() {
    return Container(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Wrap(
          children: List.generate(widget.bible.content.length, (index) => createBox(index)),
        ),
      ),
    );
  }

  Widget createBox(int index) {
    return Container(
      width: 45,
      height: 45,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xbbbbbbbb), width: 0.5),
      ),
      child: Listener(
          child: Text(widget.bible.content[index],
              style: marked[index] == 1
                  ? TextStyle(
                      decoration: TextDecoration.underline,
                      decorationColor: currentColor,
                      decorationThickness: 4.0,
                      fontSize: 20,
                    )
                  : TextStyle(
                      fontSize: 20,
                    )),
          onPointerMove: (event) {
            print(event);
          },
          onPointerSignal: (e) {
            print(e.buttons);
          },
          onPointerHover: (event) {
            // if (marked[index] == 0) {
            //   setState(() {
            //     marked[index] = 1;
            //   });
            // }
          }),
    );
  }
}
