import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';
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
    ContentFormat format = ContentFormat.shorts,
  }) {
    // Shorts thumbnails are vertical 9:16 (1080×1920); long-form video
    // thumbnails are horizontal 16:9 (1280×720). Exact pixel sizes come from
    // ContentFormat so the app, request, and preview all stay in sync.
    final isShorts = format.isShorts;
    final orientation = isShorts ? 'vertical' : 'horizontal';
    final width = format.thumbnailWidth;
    final height = format.thumbnailHeight;

    // Note: do NOT mention "YouTube"/"Shorts"/"thumbnail" in the prompt —
    // FLUX renders such words as literal text in the image. Aspect ratio is
    // controlled via width/height, not the prompt.
    final prompt = '''
A visually striking $orientation image about "$topic" in the "$category" niche.
Style: ${style.label} — ${style.description}.
High-contrast, bold dramatic composition with cinematic lighting and a clear focal subject.
Absolutely no text, no letters, no words, no captions, no watermarks, no logos, no UI elements — image only.
''';

    return ImageRequest(
      feature: AiFeature.thumbnail,
      prompt: prompt.trim(),
      width: width,
      height: height,
    );
  }
}
