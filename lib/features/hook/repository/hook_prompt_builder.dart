import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

/// Builds the AI prompt for the Hook Generator.
class HookPromptBuilder {
  HookPromptBuilder._();

  static const String schema =
      '{"hooks": ["string"], "styleTips": ["string"]}';

  static AiRequest build({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform =
        format.isShorts ? 'YouTube Shorts' : 'YouTube long-form video';
    final focus = format.isShorts
        ? 'Optimize for the first 1–3 seconds. Punchy, spoken aloud, high retention.'
        : 'Optimize for the cold open of a longer video. Curiosity without clickbait.';

    final prompt = '''
You are a YouTube retention expert. Generate exactly 12 powerful opening hooks for a $platform about "$topic" in $language.

$focus

Rules:
- Each hook must be 1–2 short sentences max.
- Mix styles: question, bold claim, pattern interrupt, story tease, number hook.
- Sound natural when spoken on camera.
- No misleading clickbait.
- Return ONLY valid JSON.

Return JSON:
{"hooks": ["hook1", "...", "hook12"], "styleTips": ["tip1", "tip2"]}
''';

    return AiRequest(
      feature: AiFeature.hook,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 600,
      temperature: 0.75,
    );
  }
}
