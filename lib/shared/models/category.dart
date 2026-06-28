/// A content category.
class Category {
  const Category({required this.id, required this.name, this.icon});
  final String id;
  final String name;
  final String? icon;

  @override
  String toString() => name;
}
