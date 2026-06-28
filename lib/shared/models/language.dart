/// A supported language for content generation.
class Language {
  const Language({required this.code, required this.name});
  final String code;
  final String name;

  @override
  String toString() => name;
}
