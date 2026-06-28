import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The content format a feature generates for.
///
/// The same 8 feature screens serve both formats; the selected format is read
/// by each feature's prompt builder (Phase 2) to adapt wording, lengths, and
/// thumbnail aspect ratio.
enum ContentFormat {
  shorts('Shorts', 'YouTube Shorts (vertical, short-form)'),
  longForm('Video', 'YouTube long-form video');

  const ContentFormat(this.label, this.description);

  final String label;
  final String description;

  bool get isShorts => this == ContentFormat.shorts;
  bool get isLongForm => this == ContentFormat.longForm;
}

/// Holds the format the user is currently working in.
///
/// Set when the user opens a feature from the Video or Short tab, then read by
/// the feature screen and threaded into generation.
final selectedFormatProvider =
    StateProvider<ContentFormat>((ref) => ContentFormat.shorts);
