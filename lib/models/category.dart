class Category {
  final String id;
  final String name;
  final String description;
  final bool active;
  final int order;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.order,
  });

  factory Category.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return Category(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      order: data['order'] as int? ?? 0,
    );
  }
}