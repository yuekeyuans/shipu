import 'package:da_ka/db/mdx/mdxEntry.dart';
import 'package:da_ka/db/mdx/mdxTag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';

typedef FunctionOneParam = void Function(MdxEntry entry);

class MdxViewIndex extends StatefulWidget {
  final FunctionOneParam onTap;
  MdxViewIndex(this.onTap);

  @override
  _MdxViewIndexState createState() => _MdxViewIndexState();
}

class _MdxViewIndexState extends State<MdxViewIndex> {
  var root = MdxTagList();
  @override
  void initState() {
    super.initState();
    updateData();
  }

  updateData() async {
    root = await root.buildTreeBySearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return createBody();
  }

  Widget createBody() {
    return TreeView(
      nodes: buildNode(root),
      indent: 0.0,
    );
  }

  List<TreeNode> buildNode(MdxTagList list) {
    var nodes = <TreeNode>[];
    list.tagsList.forEach((element) {
      nodes.add(TreeNode(
          content: Text(
            element.tag.name,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          children: buildNode(element)));
    });
    list.entriesList.forEach((element) {
      nodes.add(TreeNode(
        content: GestureDetector(
          child: Container(
            child: Text(element.entry, maxLines: 3, overflow: TextOverflow.ellipsis),
            width: 200,
          ),
          onTap: () => widget.onTap(element),
        ),
      ));
    });
    return nodes;
  }
}

//这样建立一个模型
class MdxTagList {
  MdxTag tag;
  List<MdxTagList> tagsList = [];
  List<MdxEntry> entriesList = [];

  MdxTagList();

  //db version
  Future<MdxTagList> buildTree(String tagId) async {
    MdxTagList list = MdxTagList();
    list.entriesList = await MdxEntry().queryIndexesByTag(tagId);
    var tags = await MdxTag().queryTagsByParent(tagId);
    tags.forEach((element) async {
      var tag = await buildTree(element.id);
      list.tagsList.add(tag);
    });
    if (tagId != MdxTag.TAG_ID_PARENT) {
      list.tag = await MdxTag().queryTagById(tagId);
    }
    return list;
  }

  //初始化查询模型
  var tags = <MdxTag>[];
  var entries = <MdxEntry>[];
  Future<MdxTagList> buildTreeBySearch() async {
    tags = await MdxTag().queryAllTags();
    entries = await MdxEntry().queryIndexes();
    return buildTreeRecurse(MdxTag.TAG_ID_PARENT);
  }

  //查询归类
  MdxTagList buildTreeRecurse(String tagId) {
    var list = MdxTagList();
    //entries
    entries.forEach((element) {
      if (element.tagId == tagId) {
        list.entriesList.add(element);
      }
    });
    //tags
    tags.forEach((element) {
      if (element.parentId == tagId) {
        list.tagsList.add(buildTreeRecurse(element.id));
      }
      if (element.id == tagId) {
        list.tag = element;
      }
    });
    return list;
  }
}
