import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

/// Builds the AI prompt for the Title Generator feature.
///
/// Co-located with the feature so prompts are easy to iterate on, while the
/// transport (AiService) stays generic.
class TitlePromptBuilder {
  TitlePromptBuilder._();

  /// The JSON schema hint sent to the AI for structured output.
  static const String schema = '{"titles": ["string", "string", ...]}';

  /// Builds a prompt requesting exactly 10 SEO-friendly titles.
  static AiRequest build({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform = format.isShorts ? 'YouTube Shorts video' : 'YouTube long-form video';
    final limit = format.isShorts ? 70 : 100;
    final prompt = '''
You are a YouTube SEO expert. Generate exactly 10 SEO-friendly, high-CTR titles for a $platform about "$topic" in $language.

Rules:
- Each title must be under $limit characters.
- Use power words, curiosity hooks, and emotional triggers.
- Include relevant keywords naturally.
- Avoid clickbait that misleads.
- Vary the style: questions, lists, bold claims, how-tos.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"titles": ["title1", "title2", ..., "title10"]}
''';

    return AiRequest(
      feature: AiFeature.title,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 500,
      temperature: 0.7,
    );
  }
}
