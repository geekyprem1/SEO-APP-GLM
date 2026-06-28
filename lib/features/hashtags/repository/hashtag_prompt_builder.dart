import '../../../core/services/ai/models.dart';

/// Builds the AI prompt for the Hashtag Generator feature.
class HashtagPromptBuilder {
  HashtagPromptBuilder._();

  static const String schema = '{"hashtags": ["string", "string", ...]}';

  static AiRequest build({required String topic}) {
    final prompt = '''
You are a YouTube Shorts SEO expert. Generate exactly 20 relevant, high-reach hashtags for a YouTube Shorts video about "$topic".

Rules:
- Mix broad (high volume) and niche (targeted) hashtags.
- Include trending and evergreen tags.
- Each hashtag must start with #.
- Keep each hashtag under 30 characters.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"hashtags": ["#tag1", "#tag2", ..., "#tag20"]}
''';

    return AiRequest(
      feature: AiFeature.hashtag,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 300,
      temperature: 0.7,
    );
  }
}
