import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

class CtaPromptBuilder {
  CtaPromptBuilder._();

  static const String schema = '{"ctas": ["string"]}';

  static AiRequest build({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform =
        format.isShorts ? 'YouTube Shorts' : 'YouTube long-form video';
    final focus = format.isShorts
        ? 'Focus on end-of-Short CTAs: follow, comment, part-2, like.'
        : 'Focus on end-screen / verbal CTAs: subscribe, watch next, comment.';

    final prompt = '''
You are a YouTube conversion copywriter. Generate exactly 12 strong call-to-action lines for a $platform about "$topic" in $language.

$focus

Rules:
- Each CTA is 1 short sentence, spoken or on-screen friendly.
- Mix asks: subscribe, comment, follow, watch next, share.
- No spammy ALL CAPS walls.
- Return ONLY valid JSON.

Return JSON:
{"ctas": ["cta1", "...", "cta12"]}
''';

    return AiRequest(
      feature: AiFeature.cta,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 500,
      temperature: 0.7,
    );
  }
}
