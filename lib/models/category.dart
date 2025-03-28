class Category {
  int? id;
  String name;
  bool isDefault;
  String iconName;

  Category({
    this.id, 
    required this.name, 
    this.isDefault = false,
    this.iconName = 'default'
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault ? 1 : 0,
      'iconName': iconName,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      isDefault: map['isDefault'] == 1,
      iconName: map['iconName'] ?? 'default',
    );
  }
}