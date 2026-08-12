import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

class CompetitorPromptBuilder {
  CompetitorPromptBuilder._();

  static const String schema = '{"titles": ["string"]}';

  static AiRequest build({
    required String sourceTitle,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform =
        format.isShorts ? 'YouTube Shorts' : 'YouTube long-form video';
    final limit = format.isShorts ? 70 : 100;

    final prompt = '''
You are a YouTube SEO strategist. Rewrite this competitor title into exactly 10 stronger alternatives for a $platform, in $language.

Competitor title:
"""$sourceTitle"""

Rules:
- Keep the same core topic/intent.
- Improve CTR with clearer benefit, curiosity, or specificity.
- Each title under $limit characters.
- Do NOT copy the original wording closely.
- Avoid misleading clickbait.
- Return ONLY valid JSON.

Return JSON:
{"titles": ["title1", "...", "title10"]}
''';

    return AiRequest(
      feature: AiFeature.competitor,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 500,
      temperature: 0.7,
    );
  }
}
