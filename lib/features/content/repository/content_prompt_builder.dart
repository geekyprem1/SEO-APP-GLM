import '../../../core/services/ai/models.dart';

/// Builds the AI prompt for the Content Generator feature.
class ContentPromptBuilder {
  ContentPromptBuilder._();

  static const String schema =
      '{"hook": "string", "mainContent": "string", "cta": "string"}';

  static AiRequest build({required String topic}) {
    final prompt = '''
You are a YouTube Shorts scriptwriter and SEO expert. Create a short-form video script for a YouTube Shorts about "$topic".

Structure the script in 3 parts:
1. Hook — a 1–2 sentence attention grabber (first 3 seconds).
2. Main Content — the core message (30–60 seconds of spoken content).
3. CTA — a clear call-to-action (subscribe, like, comment, etc.).

Rules:
- Keep the total script under 200 words.
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
      maxTokens: 300,
      temperature: 0.7,
    );
  }
}
