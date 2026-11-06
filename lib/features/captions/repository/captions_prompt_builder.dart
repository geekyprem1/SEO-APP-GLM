import '../../../core/services/ai/models.dart';
import '../../../core/utils/prompt_utils.dart';
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
    final safeTopic = PromptUtils.clean(topic, field: 'topic');
    final platform =
        format.isShorts ? 'YouTube Shorts' : 'YouTube long-form clip';
    final contextBlock = (context != null && context.trim().isNotEmpty)
        ? '\nOptional script context:\n"""${PromptUtils.clean(context, maxLength: PromptUtils.maxLongLength, field: 'context')}"""\n'
        : '';

    final prompt = '''
You are a short-form video editor. Generate exactly 12 on-screen caption lines for a $platform about "$safeTopic" in $language.
$contextBlock
Rules:
- Each caption is 2–8 words when possible (max ~12 words).
- Easy to read as big on-screen text.
- Mix beats: hook, build, payoff.
- Punchy, clear, no hashtags.
- ${PromptUtils.instruction}
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
