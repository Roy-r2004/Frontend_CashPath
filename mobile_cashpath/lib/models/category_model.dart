class Category {
  final String id;
  final String name;
  final String type; // "Income" or "Expense"
  final String icon;
  final String color;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.parentId,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'] ?? "",
      color: json['color'] ?? "",
      parentId: json['parent_id'],
    );
  }
}
