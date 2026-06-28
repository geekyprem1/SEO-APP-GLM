import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

/// Builds the AI prompt for the Hashtag Generator feature.
class HashtagPromptBuilder {
  HashtagPromptBuilder._();

  static const String schema = '{"hashtags": ["string", "string", ...]}';

  static AiRequest build({
    required String topic,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform = format.isShorts ? 'YouTube Shorts video' : 'YouTube long-form video';
    final prompt = '''
You are a YouTube SEO expert. Generate exactly 20 relevant, high-reach hashtags for a $platform about "$topic".

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
      maxTokens: 400,
      temperature: 0.7,
    );
  }
}
