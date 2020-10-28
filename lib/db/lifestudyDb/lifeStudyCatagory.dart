import 'dart:convert';

class LifeStudyCatagory {
  int id;
  String name;
  bool isFold = true;
  LifeStudyCatagory({
    this.id,
    this.name,
  });

  static List<LifeStudyCatagory> queryCatagory() {
    return [
      LifeStudyCatagory(id: 0, name: "旧约"),
      LifeStudyCatagory(id: 1, name: "新约"),
    ];
  }

  LifeStudyCatagory copyWith({
    int id,
    String name,
  }) {
    return LifeStudyCatagory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory LifeStudyCatagory.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return LifeStudyCatagory(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LifeStudyCatagory.fromJson(String source) => LifeStudyCatagory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'LifeStudyCatagory(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is LifeStudyCatagory && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
