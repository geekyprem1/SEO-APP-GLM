import '../models/content_duration.dart';
import '../models/content_format.dart';

/// Duration options, curated per [ContentFormat].
///
/// Shorts are capped at 60s (YouTube Shorts limit); long-form offers minute
/// ranges. The [ContentDuration.promptHint] guides the generated script length.
class DurationCatalog {
  DurationCatalog._();

  static const List<ContentDuration> _shorts = [
    ContentDuration(
        label: '15 seconds',
        promptHint: 'about 15 seconds long (~40 words of narration)'),
    ContentDuration(
        label: '30 seconds',
        promptHint: 'about 30 seconds long (~75 words of narration)'),
    ContentDuration(
        label: '60 seconds',
        promptHint: 'about 60 seconds long (~150 words of narration)'),
  ];

  static const List<ContentDuration> _longForm = [
    ContentDuration(
        label: '3–5 minutes',
        promptHint:
            'about 3 to 5 minutes long (a structured outline, not word-for-word)'),
    ContentDuration(
        label: '5–10 minutes',
        promptHint:
            'about 5 to 10 minutes long (a structured outline, not word-for-word)'),
    ContentDuration(
        label: '10+ minutes',
        promptHint:
            'about 10 minutes or more (an in-depth structured outline, not word-for-word)'),
  ];

  /// Returns the duration options available for [format].
  static List<ContentDuration> forFormat(ContentFormat format) =>
      format.isShorts ? _shorts : _longForm;

  /// Returns the default duration for [format].
  static ContentDuration defaultFor(ContentFormat format) =>
      forFormat(format).first;

  /// Resolves a stored [label] within [format], falling back to the default.
  static ContentDuration byLabel(String label, ContentFormat format) =>
      forFormat(format).firstWhere(
        (d) => d.label == label,
        orElse: () => defaultFor(format),
      );
}
