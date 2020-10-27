import 'package:da_ka/views/mdxView/mdxViewIndex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

class TestTreeView extends StatefulWidget {
  @override
  _TestTreeViewState createState() => _TestTreeViewState();
}

class _TestTreeViewState extends State<TestTreeView> {
  TreeController controller;

  @override
  void initState() {
    super.initState();
    controller = TreeController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("test tree")), body: MdxViewIndex(null));
  }
}
