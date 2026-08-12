import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_format.dart';

class SeriesPromptBuilder {
  SeriesPromptBuilder._();

  static const String schema =
      '{"ideas": [{"title": "string", "angle": "string"}]}';

  static AiRequest build({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) {
    final platform =
        format.isShorts ? 'YouTube Shorts series' : 'YouTube long-form series';
    final count = format.isShorts ? 7 : 6;

    final prompt = '''
You are a YouTube content strategist. Turn one topic into exactly $count connected episode ideas for a $platform, in $language.

Topic: "$topic"

Rules:
- Ideas should form a coherent series (part 1 → part N feel).
- Each idea: short title + one-line angle.
- Mix beginner, advanced, myth-bust, checklist, story angles.
- Return ONLY valid JSON.

Return JSON:
{"ideas": [{"title": "...", "angle": "..."}, ...]}
''';

    return AiRequest(
      feature: AiFeature.series,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 700,
      temperature: 0.75,
    );
  }
}
