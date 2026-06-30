import 'package:flutter/foundation.dart';

/// Identifies which feature is requesting AI generation.
/// Used for quota tracking, logging, and analytics.
enum AiFeature {
  title('title', 20),
  hashtag('hashtag', 20),
  description('description', 20),
  content('content', 10),
  viralIdeas('viralIdeas', 20),
  trending('trending', 20),
  seo('seo', 10),
  thumbnail('thumbnail', 3);

  const AiFeature(this.id, this.dailyLimit);

  /// Stable identifier stored in Firestore usage docs and logs.
  final String id;

  /// Per-user daily generation limit for this feature.
  final int dailyLimit;
}

/// A request to the AI service.
/// Feature-specific prompt builders construct the [prompt]; the transport
/// (AiService) stays generic.
@immutable
class AiRequest {
  const AiRequest({
    required this.feature,
    required this.prompt,
    this.schema,
    this.maxTokens = 300,
    this.temperature = 0.7,
  });

  /// Which feature is requesting generation (for quota/logging).
  final AiFeature feature;

  /// The fully-built prompt string.
  final String prompt;

  /// Optional JSON schema hint for structured output.
  final String? schema;

  /// Max tokens for the response. Default 300 (sufficient for titles/hashtags).
  final int maxTokens;

  /// Sampling temperature. Default 0.7.
  final double temperature;
}

/// The result of an AI generation call.
@immutable
class AiResult {
  const AiResult({
    required this.rawText,
    this.json,
    this.tokensUsed = 0,
    this.estimatedCost = 0.0,
  });

  /// The raw text response from the AI model.
  final String rawText;

  /// Parsed JSON if the response was structured, otherwise null.
  final Map<String, dynamic>? json;

  /// Number of tokens consumed (for logging/cost tracking).
  final int tokensUsed;

  /// Estimated USD cost of this request (for logging/budget).
  final double estimatedCost;
}

/// A request to the image generation service.
@immutable
class ImageRequest {
  const ImageRequest({
    required this.feature,
    required this.prompt,
    this.width = 768,
    this.height = 768,
  });

  final AiFeature feature;
  final String prompt;
  final int width;
  final int height;
}

/// The result of an image generation call.
@immutable
class ImageResult {
  const ImageResult({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.estimatedCost = 0.0,
  });

  final String imageUrl;
  final int width;
  final int height;
  final double estimatedCost;
}
