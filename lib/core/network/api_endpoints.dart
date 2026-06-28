/// Centralized API endpoint definitions.
/// All external API calls go through Cloud Functions — these are the
/// callable function names + any non-AI HTTP endpoints.
class ApiEndpoints {
  ApiEndpoints._();

  // Cloud Functions (callable)
  static const String generateContent = 'generateContent';
  static const String generateImage = 'generateImage';
  static const String analyzeSeo = 'analyzeSeo';

  // YouTube oEmbed (free, no key) — used as fallback for basic metadata.
  static const String youtubeOembed = 'https://www.youtube.com/oembed';
}
