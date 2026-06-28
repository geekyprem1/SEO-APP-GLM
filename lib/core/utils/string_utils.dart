/// String manipulation utilities.
class StringUtils {
  StringUtils._();

  /// Truncates a string to [maxChars] and appends "…".
  static String truncate(String text, {int maxChars = 50}) {
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}…';
  }

  /// Capitalizes the first letter.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Joins a list with commas + "and" for the last item.
  static String joinWithAnd(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first} and ${items.last}';
    return '${items.sublist(0, items.length - 1).join(', ')}, and ${items.last}';
  }

  /// Generates a SHA-256-like hash for cache keys (simple hash for MVP).
  /// For production cache keys, use crypto package sha256.
  static String simpleHash(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash &= 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
