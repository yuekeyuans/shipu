import 'package:da_ka/global.dart';
import 'package:da_ka/views/nee/neePage.dart';
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

import 'package:da_ka/db/neeDb/neeBookNameTable.dart';
import 'package:da_ka/db/neeDb/neeCatagoryTable.dart';
import 'package:da_ka/db/neeDb/neeOutlineTable.dart';
import 'package:da_ka/views/smdj/smdjViewer.dart';

class NeeIndexPage extends StatefulWidget {
  @override
  _NeeIndexPageState createState() => _NeeIndexPageState();
}

class _NeeIndexPageState extends State<NeeIndexPage> {
  List<NeeCatagoryTable> catagories = [];
  List<NeeBookNameTable> books = [];
  List<NeeOutlineTable> outlines = [];
  List<NeeItem> mixedList = [];

  @override
  void initState() {
    super.initState();
    updateData();
  }

  Future<void> updateData() async {
    catagories = NeeCatagoryTable.queryCatagory();
    books = await NeeBookNameTable.queryBooks();
    outlines = await NeeOutlineTable.queryChapters();
    buildCatagories();
  }

  void buildCatagories() {
    mixedList = [];
    catagories.forEach((element) {
      mixedList.add(NeeItem(type: 0, isFold: element.isFold, catagory: element));
      if (!element.isFold) {
        buildBookNames(element);
      }
    });
    setState(() {});
  }

  void buildBookNames(NeeCatagoryTable catagory) {
    books.forEach((element) {
      var bookNumber = int.parse(element.bookNumber.split("-").first);
      if (bookNumber == catagory.id) {
        mixedList.add(NeeItem(type: 1, isFold: element.isFold, book: element));
        if (!element.isFold) {
          buildOutlines(element);
        }
      }
    });
  }

  void buildOutlines(NeeBookNameTable bookName) {
    outlines.forEach((element) {
      if (element.bookIndex == bookName.bookIndex) {
        mixedList.add(NeeItem(type: 2, chapter: element));
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("倪柝声文集")),
      body: Container(
        child: createList(),
        color: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light ? backgroundGray : Colors.black,
    );
  }

  ListView createList() {
    return ListView.separated(
        itemBuilder: (_, index) {
          var element = mixedList[index];
          if (element.type == 0 || element.type == 1) {
            String name = element.type == 0 ? element.catagory.name : element.book.name;
            return InkWell(
                child: ListTile(
                    isThreeLine: false,
                    title: Row(
                      children: [
                        SizedBox(width: element.type * 20.0),
                        PreferredSize(
                            child: PreferredSize(
                              child: element.isFold ? Icon(Icons.arrow_right) : Icon(Icons.arrow_drop_down),
                              preferredSize: Size.fromWidth(10),
                            ),
                            preferredSize: Size.fromWidth(10)),
                        Expanded(child: Text(name, style: TextStyle(fontWeight: FontWeight.w900), textAlign: TextAlign.left)),
                      ],
                    )),
                onTap: () {
                  element.isFold = !element.isFold;
                  element.type == 0 ? (element.catagory.isFold = element.isFold) : (element.book.isFold = element.isFold);
                  buildCatagories();
                });
          }
          return InkWell(
              child: ListTile(
                title: Row(children: [
                  SizedBox(width: element.type * 20.0 + 20),
                  Expanded(child: Text(element.chapter.content)),
                ]),
                dense: false,
                isThreeLine: false,
                contentPadding: EdgeInsets.all(0),
              ),
              onTap: () => routePush(NeePage(element.chapter.bookIndex, element.chapter.chapter)));
        },
        separatorBuilder: (_, index) {
          return Divider(height: 1.0);
        },
        itemCount: mixedList.length);
  }
}

class NeeItem {
  // 0 => 卷
  // 1 =>book
  // 2 =>chapter
  int type = 0;
  bool isFold = true;
  NeeCatagoryTable catagory;
  NeeBookNameTable book;
  NeeOutlineTable chapter;
  NeeItem({
    this.type,
    this.isFold,
    this.catagory,
    this.book,
    this.chapter,
  });

  NeeItem copyWith({
    int type,
    bool isFold,
    NeeCatagoryTable catagory,
    NeeBookNameTable book,
    NeeOutlineTable chapter,
  }) {
    return NeeItem(
      type: type ?? this.type,
      isFold: isFold ?? this.isFold,
      catagory: catagory ?? this.catagory,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
    );
  }

  @override
  String toString() {
    return 'NeeItem(type: $type, isFold: $isFold, catagory: $catagory, book: $book, chapter: $chapter)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NeeItem && o.type == type && o.isFold == isFold && o.catagory == catagory && o.book == book && o.chapter == chapter;
  }

  @override
  int get hashCode {
    return type.hashCode ^ isFold.hashCode ^ catagory.hashCode ^ book.hashCode ^ chapter.hashCode;
  }
}
