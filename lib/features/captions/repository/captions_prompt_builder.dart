import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

class CaptionsPromptBuilder {
  CaptionsPromptBuilder._();

  static const String schema =
      '{"captions": [{"text": "string", "beats": "hook|build|payoff"}]}';

  static AiRequest build({
    required String topic,
    required String language,
    String? context,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform =
        format.isShorts ? 'YouTube Shorts' : 'YouTube long-form clip';
    final contextBlock = (context != null && context.trim().isNotEmpty)
        ? '\nOptional script context:\n"""${context.trim()}"""\n'
        : '';

    final prompt = '''
You are a short-form video editor. Generate exactly 12 on-screen caption lines for a $platform about "$topic" in $language.
$contextBlock
Rules:
- Each caption is 2–8 words when possible (max ~12 words).
- Easy to read as big on-screen text.
- Mix beats: hook, build, payoff.
- Punchy, clear, no hashtags.
- Return ONLY valid JSON.

Return JSON:
{"captions": [{"text": "...", "beats": "hook"}, ...]}
''';

    return AiRequest(
      feature: AiFeature.captions,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 500,
      temperature: 0.7,
    );
  }
}
