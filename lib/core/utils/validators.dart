/// Input validation utilities for all features.
class Validators {
  Validators._();

  /// Non-empty after trim, within [min]–[max] length.
  static String? validateTopic(String? value, {int min = 3, int max = 120, String field = 'Topic'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required.';
    }
    final trimmed = value.trim();
    if (trimmed.length < min) {
      return '$field must be at least $min characters.';
    }
    if (trimmed.length > max) {
      return '$field must be at most $max characters.';
    }
    return null;
  }

  /// Required selection (dropdown).
  static String? validateRequired(dynamic value, {String field = 'This field'}) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return '$field is required.';
    }
    return null;
  }

  /// YouTube Shorts URL validation.
  /// Accepts: youtube.com/shorts/VIDEO_ID, youtu.be/VIDEO_ID, youtube.com/watch?v=VIDEO_ID
  static String? validateYouTubeUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'YouTube URL is required.';
    }
    final url = value.trim();
    final pattern = RegExp(
      r'^(https?://)?(www\.)?(youtube\.com/(shorts/|watch\?v=)|youtu\.be/)[\w-]{11}',
      caseSensitive: false,
    );
    if (!pattern.hasMatch(url)) {
      return 'Enter a valid YouTube Shorts URL.';
    }
    return null;
  }

  /// Extracts the 11-char video ID from a YouTube URL, or null.
  static String? extractVideoId(String url) {
    final patterns = [
      RegExp(r'youtube\.com/shorts/([\w-]{11})'),
      RegExp(r'youtu\.be/([\w-]{11})'),
      RegExp(r'[?&]v=([\w-]{11})'),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(url);
      if (match != null) return match.group(1);
    }
    return null;
  }

  /// Trims and normalizes whitespace.
  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
