//伪表 倪文集卷
class NeeCatagoryTable {
  bool isFold = true;
  int id;
  String name;
  NeeCatagoryTable({
    this.id,
    this.name,
  });

  static List<NeeCatagoryTable> queryCatagory() {
    return [
      NeeCatagoryTable(id: 1, name: "卷一"),
      NeeCatagoryTable(id: 2, name: "卷二"),
      NeeCatagoryTable(id: 3, name: "卷三"),
    ];
  }
}
