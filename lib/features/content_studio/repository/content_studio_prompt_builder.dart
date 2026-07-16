import '../../../core/services/ai/models.dart';
import '../../../shared/models/content_duration.dart';
import '../../../shared/models/content_format.dart';
import '../../../shared/models/tone.dart';

/// Builds the AI prompt for the AI Content Studio.
///
/// Produces a single request that returns an all-in-one content package
/// (titles, hook, script, description, keywords, hashtags, thumbnail text
/// ideas, and CTA) tailored to the selected format, language, tone, and
/// duration.
class ContentStudioPromptBuilder {
  ContentStudioPromptBuilder._();

  static const String schema =
      '{"titles": ["string"], "hook": "string", "script": "string", '
      '"description": "string", "keywords": ["string"], "hashtags": ["string"], '
      '"thumbnailTextIdeas": ["string"], "cta": "string"}';

  static AiRequest build({
    required String topic,
    required ContentFormat format,
    required String language,
    required Tone tone,
    required ContentDuration duration,
  }) {
    final platform =
        format.isShorts ? 'YouTube Shorts (vertical short-form)' : 'YouTube long-form video';

    final scriptRule = format.isShorts
        ? '- "script": a complete, word-for-word narration script that is ${duration.promptHint}. Keep it tight and punchy.'
        : '- "script": a structured script that is ${duration.promptHint}. Use an intro, 3–5 clearly labelled sections with key talking points, and an outro. Do NOT write every word verbatim — keep it as a usable outline.';

    final prompt = '''
You are an expert YouTube content strategist, scriptwriter, and SEO specialist. Create a complete, ready-to-publish content package for a $platform about "$topic".

Write ALL text in $language, using a ${tone.promptHint} tone.

Return a JSON object with EXACTLY these fields:
- "titles": an array of at least 3 catchy, SEO-friendly title options (each under 100 characters).
- "hook": a single first-three-seconds opening line that instantly grabs attention.
$scriptRule
- "description": an SEO-optimised description that naturally includes the main keyword.
- "keywords": an array of at least 5 relevant SEO keywords (no leading symbols).
- "hashtags": an array of at least 5 relevant hashtags, each starting with '#'.
- "thumbnailTextIdeas": an array of at least 3 short, punchy thumbnail text overlays (2–4 words each).
- "cta": a single clear call-to-action line (subscribe, like, comment, follow, etc.).

Rules:
- Tailor every field to the topic, format, tone, and target length.
- Include the main keyword naturally throughout.
- Return ONLY valid JSON — no markdown, code fences, or extra commentary.

Return JSON in this exact shape:
$schema
''';

    return AiRequest(
      feature: AiFeature.contentStudio,
      prompt: prompt.trim(),
      schema: schema,
      // Server clamps to 1000; request the full budget for an all-in-one package.
      maxTokens: 1000,
      temperature: 0.7,
    );
  }
}
