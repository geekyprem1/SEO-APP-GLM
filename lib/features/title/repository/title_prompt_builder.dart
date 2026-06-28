import '../../../core/services/ai/models.dart';

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
  }) {
    final prompt = '''
You are a YouTube Shorts SEO expert. Generate exactly 10 SEO-friendly, high-CTR titles for a YouTube Shorts video about "$topic" in $language.

Rules:
- Each title must be under 70 characters (YouTube title display limit).
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
      maxTokens: 300,
      temperature: 0.7,
    );
  }
}
