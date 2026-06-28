import '../../../core/services/ai/models.dart';

/// Builds the AI prompt for the Trending Topics feature.
class TrendingPromptBuilder {
  TrendingPromptBuilder._();

  static const String schema = '{"topics": ["string", "string", ...]}';

  static AiRequest build({
    required String category,
    required String country,
    required String language,
  }) {
    final prompt = '''
You are a YouTube Shorts trends analyst. Generate a list of 15 currently trending topics in the "$category" niche for audiences in $country, in $language.

Rules:
- Base topics on real trends, viral formats, and popular content patterns.
- Each topic should be specific and actionable.
- Keep each topic under 80 characters.
- Include a mix of evergreen and timely trends.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"topics": ["topic1", "topic2", ..., "topic15"]}
''';

    return AiRequest(
      feature: AiFeature.trending,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 800,
      temperature: 0.7,
    );
  }
}
