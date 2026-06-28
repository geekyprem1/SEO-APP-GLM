import 'models.dart';

/// Abstract AI service interface.
///
/// All generators call this single service. Changing the AI provider
/// (OpenRouter → another) requires only implementing this interface and
/// changing the Riverpod override in one place — no UI changes.
///
/// MVP implementation: [CloudFunctionsAiService] which routes requests
/// through Firebase Cloud Functions (API key stays server-side).
abstract class AiService {
  /// Generates content for the given [request].
  ///
  /// Throws [Failure] (via the repository's error handler) on:
  /// - network/timeout errors
  /// - quota exceeded
  /// - budget exceeded
  /// - rate limit
  /// - API errors
  Future<AiResult> generate({required AiRequest request});
}
