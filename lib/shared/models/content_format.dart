import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The content format a feature generates for.
///
/// The same 8 feature screens serve both formats; the selected format is read
/// by each feature's prompt builder (Phase 2) to adapt wording, lengths, and
/// thumbnail aspect ratio.
enum ContentFormat {
  // Thumbnail resolutions follow YouTube's spec per format:
  //  - Shorts:    1080×1920 (9:16, full-screen vertical mobile)
  //  - Long-form: 1280×720  (16:9, YouTube's recommended size / 1280px min width)
  shorts('Shorts', 'YouTube Shorts (vertical, short-form)', 1080, 1920),
  longForm('Video', 'YouTube long-form video', 1280, 720);

  const ContentFormat(
    this.label,
    this.description,
    this.thumbnailWidth,
    this.thumbnailHeight,
  );

  final String label;
  final String description;

  /// Target thumbnail width in pixels for this format (YouTube spec).
  final int thumbnailWidth;

  /// Target thumbnail height in pixels for this format (YouTube spec).
  final int thumbnailHeight;

  bool get isShorts => this == ContentFormat.shorts;
  bool get isLongForm => this == ContentFormat.longForm;

  /// Aspect ratio (width / height) — used for distortion-free preview layout.
  double get thumbnailAspectRatio => thumbnailWidth / thumbnailHeight;
}

/// Holds the format the user is currently working in.
///
/// Set when the user opens a feature from the Video or Short tab, then read by
/// the feature screen and threaded into generation.
final selectedFormatProvider =
    StateProvider<ContentFormat>((ref) => ContentFormat.shorts);
