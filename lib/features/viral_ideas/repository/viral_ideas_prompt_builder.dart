import '../../../core/services/ai/models.dart';

/// Builds the AI prompt for the Viral Shorts Ideas feature.
class ViralIdeasPromptBuilder {
  ViralIdeasPromptBuilder._();

  static const String schema = '{"ideas": ["string", "string", ...]}';

  static AiRequest build({required String category, required String language}) {
    final prompt = '''
You are a YouTube Shorts content strategist. Generate exactly 20 viral content ideas for the "$category" niche in $language.

Rules:
- Each idea should be a specific, actionable video concept (not just a topic).
- Include a mix of trending formats: challenges, listicles, tutorials, reactions, storytelling.
- Keep each idea under 80 characters.
- Make them highly shareable and engaging.
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"ideas": ["idea1", "idea2", ..., "idea20"]}
''';

    return AiRequest(
      feature: AiFeature.viralIdeas,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 1000,
      temperature: 0.8,
    );
  }
}
