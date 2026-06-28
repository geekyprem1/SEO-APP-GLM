import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

/// Builds the AI prompt for the Description Generator feature.
class DescriptionPromptBuilder {
  DescriptionPromptBuilder._();

  static const String schema = '{"description": "string"}';

  static AiRequest build({
    required String topic,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform = format.isShorts ? 'YouTube Shorts' : 'YouTube long-form video';
    final words = format.isShorts ? '150–300' : '300–500';
    final extra = format.isShorts
        ? ''
        : '- Add a "Timestamps/Chapters" section and a "Links" section.\n';
    final prompt = '''
You are a YouTube SEO expert. Write an SEO-optimized $platform description for a video about "$topic".

Rules:
- $words words.
- Include the main keyword in the first 2 lines.
- Add a brief hook and a call-to-action.
$extra- Include 5–8 relevant hashtags at the end.
- Use line breaks for readability.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"description": "the full description text here"}
''';

    return AiRequest(
      feature: AiFeature.description,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 900,
      temperature: 0.7,
    );
  }
}
