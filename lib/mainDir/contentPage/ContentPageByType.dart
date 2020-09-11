import 'package:da_ka/db/mainDb/contentFileInfoTable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';

class ContentPageByType extends StatefulWidget {
  final List<ContentFileInfoTable> list;
  final String title;

  ContentPageByType({Key key, this.title, this.list}) : super(key: key);

  @override
  _ContentPageByTypeState createState() => _ContentPageByTypeState(this.list);
}

class _ContentPageByTypeState extends State<ContentPageByType> {
  String _selectedNode;
  List<Node> _nodes = [];
  TreeViewController _treeViewController;

  var lst = <ContentFileInfoTable>[];
  var docs = <ContentFileInfoTable>[];
  var pdfs = <ContentFileInfoTable>[];
  //var images = <ContentFileInfoTable>[];
  var dicts = <ContentFileInfoTable>[];

  _ContentPageByTypeState(this.dicts) {
    if (this.dicts == null) {
      this.dicts = [];
    }
  }

  @override
  void initState() {
    super.initState();

    _treeViewController = TreeViewController(
      children: _nodes,
      selectedKey: _selectedNode,
    );

    queryData();
  }

  Future<void> queryData() async {
    lst = await ContentFileInfoTable().queryAll();
    for (var i in lst) {
      if (i.filename.endsWith(".dict")) {
        dicts.add(i);
      } else if (i.filename.endsWith(".pdf")) {
        pdfs.add(i);
      } else if (i.filename.endsWith(".doc") || i.filename.endsWith(".docx")) {
        docs.add(i);
      }
    }
    createNode();
  }

  createNode() {
    _nodes = [];
    var nodeMap = {
      "字典文件": dicts,
      "pdf 文件": pdfs,
      "word 文件": docs,
    };

    nodeMap.forEach((key, value) {
      _nodes.add(Node(
          key: key,
          label: key,
          icon: NodeIcon.fromIconData(Icons.folder_open),
          children: value
              .map((e) => Node(key: e.filepath, label: e.filename, data: e))
              .toList()));
    });

    setState(() {
      _treeViewController = TreeViewController(
        children: _nodes,
        selectedKey: _selectedNode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    TreeViewTheme _treeViewTheme = TreeViewTheme(
        labelStyle: TextStyle(
          fontSize: 16,
          letterSpacing: 0.3,
        ),
        parentLabelStyle: TextStyle(
          fontSize: 16,
          letterSpacing: 0.1,
          fontWeight: FontWeight.w800,
          color: Colors.blue.shade700,
        ),
        iconTheme: IconThemeData(
          size: 18,
          color: Colors.grey.shade800,
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade50,
          onPrimary: Colors.grey.shade900,
          background: Colors.transparent,
          onBackground: Colors.black,
        ));
    return Container(
      child: Container(
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              child: TreeView(
                controller: _treeViewController,
                onExpansionChanged: (key, expanded) =>
                    _expandNode(key, expanded),
                onNodeTap: (key) {
                  debugPrint('Selected: $key');
                  setState(() {
                    _selectedNode = key;
                    _treeViewController =
                        _treeViewController.copyWith(selectedKey: key);
                  });
                },
                theme: _treeViewTheme,
              ),
            )
          ],
        ),
      ),
    );
  }

  _expandNode(String key, bool expanded) {
    Node node = _treeViewController.getNode(key);
    if (node != null) {
      List<Node> updated;

      updated = _treeViewController.updateNode(
          key, node.copyWith(expanded: expanded));

      setState(() {
        _treeViewController = _treeViewController.copyWith(children: updated);
      });
    }
  }
}
