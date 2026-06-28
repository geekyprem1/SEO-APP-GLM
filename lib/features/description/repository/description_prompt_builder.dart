import '../../../core/services/ai/models.dart';

/// Builds the AI prompt for the Description Generator feature.
class DescriptionPromptBuilder {
  DescriptionPromptBuilder._();

  static const String schema = '{"description": "string"}';

  static AiRequest build({required String topic}) {
    final prompt = '''
You are a YouTube Shorts SEO expert. Write an SEO-optimized YouTube Shorts description for a video about "$topic".

Rules:
- 150–300 words.
- Include the main keyword in the first 2 lines.
- Add a brief hook and a call-to-action.
- Include 5–8 relevant hashtags at the end.
- Use line breaks for readability.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"description": "the full description text here"}
''';

    return AiRequest(
      feature: AiFeature.description,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 300,
      temperature: 0.7,
    );
  }
}
