import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

class ChaptersPromptBuilder {
  ChaptersPromptBuilder._();

  static const String schema =
      '{"chapters": [{"time": "0:00", "title": "string"}], "descriptionBlock": "string"}';

  static AiRequest build({
    required String topic,
    required String language,
    required String durationLabel,
    ContentFormat format = ContentFormat.longForm,
  }) {
    final platform =
        format.isShorts ? 'short-form video (~60s)' : 'YouTube long-form video';
    final countHint = format.isShorts
        ? 'Return 4–6 short beats with times like 0:00, 0:08, 0:20.'
        : 'Return 8–12 chapters with realistic timestamps for a $durationLabel video.';

    final prompt = '''
You are a YouTube packaging expert. Create chapter timestamps for a $platform about "$topic" in $language.
Target length: $durationLabel.
$countHint

Rules:
- First chapter must start at 0:00.
- Titles should be clear and SEO-friendly (3–6 words).
- Times must be ascending and realistic.
- Also return descriptionBlock: plain text lines "M:SS Title" ready to paste into YouTube description.
- Return ONLY valid JSON.

Return JSON:
{"chapters": [{"time": "0:00", "title": "Intro"}, ...], "descriptionBlock": "0:00 Intro\\n..."}
''';

    return AiRequest(
      feature: AiFeature.chapters,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 800,
      temperature: 0.6,
    );
  }
}
