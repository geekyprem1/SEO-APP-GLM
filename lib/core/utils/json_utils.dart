/// Safe helpers for parsing AI / history JSON payloads.
class JsonUtils {
  JsonUtils._();

  /// Coerces a dynamic JSON value into a list of non-empty strings.
  ///
  /// Never throws on mixed element types (numbers, maps, nulls) — those are
  /// stringified when sensible, otherwise skipped. Prevents `.cast<String>()`
  /// crashes when the model returns slightly off-schema lists.
  static List<String> stringList(dynamic value) {
    if (value is! List) return const [];
    final out = <String>[];
    for (final item in value) {
      if (item == null) continue;
      if (item is String) {
        final t = item.trim();
        if (t.isNotEmpty) out.add(item);
        continue;
      }
      if (item is num || item is bool) {
        out.add(item.toString());
        continue;
      }
      // Maps / nested lists are not valid list-of-string items.
    }
    return out;
  }
}
