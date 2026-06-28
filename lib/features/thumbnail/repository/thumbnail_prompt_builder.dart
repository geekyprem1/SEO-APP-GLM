import '../../../core/services/ai/models.dart';
import '../models/generated_thumbnail.dart';

/// Builds the image generation prompt for the Thumbnail Generator feature.
///
/// Translates user inputs (topic, category, style) into a detailed image
/// prompt optimized for FLUX.1 Schnell.
class ThumbnailPromptBuilder {
  ThumbnailPromptBuilder._();

  /// Builds an [ImageRequest] for thumbnail generation.
  static ImageRequest build({
    required String topic,
    required String category,
    required ThumbnailStyle style,
  }) {
    // Note: do NOT mention "YouTube"/"Shorts"/"thumbnail" in the prompt —
    // FLUX renders such words as literal text in the image. Aspect ratio is
    // controlled via width/height, not the prompt.
    final prompt = '''
A visually striking vertical image about "$topic" in the "$category" niche.
Style: ${style.label} — ${style.description}.
High-contrast, bold dramatic composition with cinematic lighting and a clear focal subject.
Absolutely no text, no letters, no words, no captions, no watermarks, no logos, no UI elements — image only.
''';

    return ImageRequest(
      feature: AiFeature.thumbnail,
      prompt: prompt.trim(),
      // YouTube Shorts thumbnails are vertical 9:16 (720x1280).
      width: 720,
      height: 1280,
    );
  }
}
