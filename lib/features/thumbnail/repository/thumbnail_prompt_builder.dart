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
    final prompt = '''
YouTube Shorts thumbnail image, vertical 9:16 aspect ratio, about "$topic" in the "$category" niche.
Style: ${style.label} — ${style.description}.
Make it visually striking, high-contrast, with bold readable composition suitable for a short-form video thumbnail.
No text overlays, no watermarks, no logos.
''';

    return ImageRequest(
      feature: AiFeature.thumbnail,
      prompt: prompt.trim(),
      width: 768,
      height: 768,
    );
  }
}
