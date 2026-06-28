import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

/// Builds the AI prompt for the Content Generator feature.
class ContentPromptBuilder {
  ContentPromptBuilder._();

  static const String schema =
      '{"hook": "string", "mainContent": "string", "cta": "string"}';

  static AiRequest build({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform = format.isShorts ? 'YouTube Shorts' : 'YouTube long-form video';
    final mainDesc = format.isShorts
        ? 'the core message (30–60 seconds of spoken content)'
        : 'the core message broken into 3–5 clear sections/key points (5–10 minutes of spoken content)';
    final lengthRule = format.isShorts
        ? '- Keep the total script under 200 words.'
        : '- Total script 400–700 words, structured for a multi-minute video.';
    final prompt = '''
You are a YouTube scriptwriter and SEO expert. Create a $platform script about "$topic". Write the entire script (hook, main content, CTA) in $language.

Structure the script in 3 parts:
1. Hook — a 1–2 sentence attention grabber (first few seconds).
2. Main Content — $mainDesc.
3. CTA — a clear call-to-action (subscribe, like, comment, etc.).

Rules:
$lengthRule
- Use conversational, engaging language.
- Include the main keyword naturally.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"hook": "...", "mainContent": "...", "cta": "..."}
''';

    return AiRequest(
      feature: AiFeature.content,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 900,
      temperature: 0.7,
    );
  }
}
