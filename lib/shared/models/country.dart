/// A country for trending topics.
class Country {
  const Country({required this.code, required this.name});
  final String code;
  final String name;

  @override
  String toString() => name;
}
