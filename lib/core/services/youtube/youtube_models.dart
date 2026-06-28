import 'package:flutter/foundation.dart';

/// Metadata for a YouTube video (from YouTube Data API v3).
@immutable
class YouTubeVideo {
  const YouTubeVideo({
    required this.videoId,
    required this.title,
    this.description,
    this.channelId,
    this.channelTitle,
    this.thumbnailUrl,
    this.tags = const [],
    this.viewCount,
    this.likeCount,
    this.commentCount,
    this.publishedAt,
  });

  final String videoId;
  final String title;
  final String? description;
  final String? channelId;
  final String? channelTitle;
  final String? thumbnailUrl;
  final List<String> tags;
  final int? viewCount;
  final int? likeCount;
  final int? commentCount;
  final DateTime? publishedAt;
}

/// Metadata for a YouTube channel.
@immutable
class YouTubeChannel {
  const YouTubeChannel({
    required this.channelId,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.subscriberCount,
    this.videoCount,
    this.viewCount,
  });

  final String channelId;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final int? subscriberCount;
  final int? videoCount;
  final int? viewCount;
}

/// A single search result from YouTube.
@immutable
class YouTubeSearchResult {
  const YouTubeSearchResult({
    required this.videoId,
    required this.title,
    this.channelTitle,
    this.thumbnailUrl,
    this.publishedAt,
  });

  final String videoId;
  final String title;
  final String? channelTitle;
  final String? thumbnailUrl;
  final DateTime? publishedAt;
}
