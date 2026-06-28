import 'package:flutter/foundation.dart';

/// The output of the SEO Analysis feature.
@immutable
class SeoAnalysis {
  const SeoAnalysis({
    required this.id,
    required this.videoUrl,
    required this.videoId,
    this.title,
    this.description,
    this.channelTitle,
    this.thumbnailUrl,
    this.tags = const [],
    this.viewCount,
    this.likeCount,
    this.commentCount,
    required this.score,
    required this.suggestions,
    required this.createdAt,
  });

  final String id;
  final String videoUrl;
  final String videoId;

  // Video metadata (from YouTube Data API v3)
  final String? title;
  final String? description;
  final String? channelTitle;
  final String? thumbnailUrl;
  final List<String> tags;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;

  // AI analysis results
  final int score; // 0–100
  final List<String> suggestions;

  final DateTime createdAt;

  factory SeoAnalysis.fromAiJson({
    required String id,
    required String videoUrl,
    required String videoId,
    required Map<String, dynamic> metadata,
    required Map<String, dynamic> analysis,
    required DateTime createdAt,
  }) {
    return SeoAnalysis(
      id: id,
      videoUrl: videoUrl,
      videoId: videoId,
      title: metadata['title'] as String?,
      description: metadata['description'] as String?,
      channelTitle: metadata['channelTitle'] as String?,
      thumbnailUrl: metadata['thumbnailUrl'] as String?,
      tags: (metadata['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      viewCount: metadata['viewCount'] as int?,
      likeCount: metadata['likeCount'] as int?,
      commentCount: metadata['commentCount'] as int?,
      score: (analysis['score'] as num?)?.toInt() ?? 0,
      suggestions: (analysis['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoUrl': videoUrl,
        'videoId': videoId,
        'title': title,
        'description': description,
        'channelTitle': channelTitle,
        'thumbnailUrl': thumbnailUrl,
        'tags': tags,
        'viewCount': viewCount,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'score': score,
        'suggestions': suggestions,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SeoAnalysis.fromJson(Map<String, dynamic> json) {
    return SeoAnalysis(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String,
      videoId: json['videoId'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      viewCount: json['viewCount'] as int?,
      likeCount: json['likeCount'] as int?,
      commentCount: json['commentCount'] as int?,
      score: json['score'] as int? ?? 0,
      suggestions: (json['suggestions'] as List<dynamic>?)?.cast<String>() ?? const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Returns a rating label based on the score.
  String get scoreLabel {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Needs Work';
    return 'Poor';
  }

  /// Returns a color for the score (0–100).
  int get scoreColorValue => score;

  String get shareText => '''SEO Analysis Report
Score: $score/100 ($scoreLabel)

Video: $title
Channel: $channelTitle

Suggestions:
${suggestions.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}''';

  @override
  String toString() => 'SeoAnalysis(videoId: $videoId, score: $score)';
}
