import '../../../core/services/ai/models.dart';
import '../../../core/utils/prompt_utils.dart';
import '../../../shared/models/content_format.dart';

/// Builds the AI prompt for the SEO Analysis feature.
///
/// Takes video metadata (title, description, tags, stats) and asks the AI
/// to produce an SEO score and actionable improvement suggestions.
class SeoPromptBuilder {
  SeoPromptBuilder._();

  static const String schema =
      '{"score": number, "suggestions": ["string", "string", ...]}';

  /// Builds an [AiRequest] for SEO analysis.
  ///
  /// [metadata] is the serialized YouTube video metadata (title, description,
  /// tags, viewCount, etc.) fetched via [YouTubeService].
  static AiRequest build({
    required Map<String, dynamic> metadata,
    ContentFormat format = ContentFormat.shorts,
  }) {
    // Metadata is untrusted video text — sanitize before interpolating into
    // the prompt, and bound every field (tags were previously unbounded).
    final title = PromptUtils.cleanOr(metadata['title']?.toString() ?? '');
    final channelTitle =
        PromptUtils.cleanOr(metadata['channelTitle']?.toString() ?? '');
    final description = PromptUtils.cleanOr(
      metadata['description']?.toString() ?? '',
      maxLength: PromptUtils.maxLongLength,
      fallback: '(none)',
    );
    final rawTags = metadata['tags'];
    final tags = PromptUtils.cleanOr(
      rawTags is List ? rawTags.join(', ') : rawTags?.toString() ?? '',
      maxLength: 300,
      fallback: '(none)',
    );
    final viewCount = metadata['viewCount'] ?? 0;
    final likeCount = metadata['likeCount'] ?? 0;
    final commentCount = metadata['commentCount'] ?? 0;
    final platform = format.isShorts ? 'YouTube Shorts' : 'YouTube long-form video';

    final prompt = '''
You are a $platform SEO analyst. Analyze the following video metadata and provide an SEO score (0–100) and actionable improvement suggestions.

Video Metadata:
- Title: $title
- Channel: $channelTitle
- Description: $description
- Tags: $tags
- Views: $viewCount
- Likes: $likeCount
- Comments: $commentCount

Analysis Criteria:
1. Title optimization (keywords, length, hook factor)
2. Description quality (keywords, structure, links)
3. Tag relevance and coverage
4. Engagement rate (likes/views, comments/views)
5. Overall discoverability

Rules:
- Score 0–100 where 100 is perfectly optimized.
- Provide 5–8 specific, actionable suggestions to improve SEO.
- Each suggestion should be under 120 characters.
- ${PromptUtils.instruction}
- Return ONLY valid JSON, no markdown or extra text.

Return JSON in this exact format:
{"score": 75, "suggestions": ["suggestion1", "suggestion2", ...]}
''';

    return AiRequest(
      feature: AiFeature.seo,
      prompt: prompt.trim(),
      schema: schema,
      maxTokens: 600,
      temperature: 0.5, // Lower temperature for more consistent analysis
    );
  }
}
