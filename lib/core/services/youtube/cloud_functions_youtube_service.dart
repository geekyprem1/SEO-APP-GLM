import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_constants.dart';
import '../../error/error_handler.dart';
import '../../error/exceptions.dart';
import '../../utils/json_utils.dart';
import 'youtube_models.dart';
import 'youtube_service.dart';

/// Cloud Functions implementation of [YouTubeService].
///
/// Calls the `analyzeSeo` callable Cloud Function (and related helpers) which
/// use the YouTube Data API v3 with a server-side API key.
class CloudFunctionsYouTubeService implements YouTubeService {
  CloudFunctionsYouTubeService(this._functions, this._errorHandler);

  final FirebaseFunctions _functions;
  final ErrorHandler _errorHandler;

  @override
  Future<YouTubeVideo> fetchVideoMetadata({required String videoUrlOrId}) async {
    try {
    final callable = _functions.httpsCallable(AppConstants.analyzeSeoFunction);
      final response = await callable.call<dynamic>({
        'action': 'fetchVideo',
        'videoUrlOrId': videoUrlOrId,
      });

      final data = _responseMap(response.data);
      _checkError(data);
      final video = _mapOrNull(data['video']);
      if (video == null) {
        throw ApiException('Video not found.', statusCode: 404);
      }
      final parsed = _parseVideo(video);
      if (parsed.videoId.isEmpty) {
        throw ApiException('Video not found.', statusCode: 404);
      }
      return parsed;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<YouTubeChannel> fetchChannelInfo({required String channelId}) async {
    try {
    final callable = _functions.httpsCallable(AppConstants.analyzeSeoFunction);
      final response = await callable.call<dynamic>({
        'action': 'fetchChannel',
        'channelId': channelId,
      });

      final data = _responseMap(response.data);
      _checkError(data);
      final channel = _mapOrNull(data['channel']);
      if (channel == null) {
        throw ApiException('Channel not found.', statusCode: 404);
      }
      final parsed = _parseChannel(channel);
      if (parsed.channelId.isEmpty) {
        throw ApiException('Channel not found.', statusCode: 404);
      }
      return parsed;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<List<YouTubeSearchResult>> search({
    required String query,
    int maxResults = 10,
  }) async {
    try {
    final callable = _functions.httpsCallable(AppConstants.analyzeSeoFunction);
      final response = await callable.call<dynamic>({
        'action': 'search',
        'query': query,
        'maxResults': maxResults,
      });

      final data = _responseMap(response.data);
      _checkError(data);
      final items = data['results'] as List<dynamic>? ?? [];
      return items
          .whereType<Map>()
          .map((e) => _parseSearchResult(Map<String, dynamic>.from(e)))
          .where((r) => r.videoId.isNotEmpty)
          .toList();
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  /// Normalizes a callable response payload to a JSON map, rejecting
  /// null / non-map shapes instead of crashing with a cast error.
  Map<String, dynamic> _responseMap(dynamic payload) {
    final decoded = jsonDecode(jsonEncode(payload));
    if (decoded is! Map) {
      throw ApiException('Unexpected server response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Map<String, dynamic>? _mapOrNull(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  void _checkError(Map<String, dynamic> data) {
    final error = data['error'] as String?;
    if (error != null) {
      final code = data['errorCode'] as String? ?? 'UNKNOWN';
      throw ApiException(error, code: code);
    }
  }

  YouTubeVideo _parseVideo(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      channelId: json['channelId'] as String?,
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      tags: JsonUtils.stringList(json['tags']),
      viewCount: (json['viewCount'] as num?)?.toInt(),
      likeCount: (json['likeCount'] as num?)?.toInt(),
      commentCount: (json['commentCount'] as num?)?.toInt(),
      publishedAt: json['publishedAt'] is String
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }

  YouTubeChannel _parseChannel(Map<String, dynamic> json) {
    return YouTubeChannel(
      channelId: json['channelId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      subscriberCount: (json['subscriberCount'] as num?)?.toInt(),
      videoCount: (json['videoCount'] as num?)?.toInt(),
      viewCount: (json['viewCount'] as num?)?.toInt(),
    );
  }

  YouTubeSearchResult _parseSearchResult(Map<String, dynamic> json) {
    return YouTubeSearchResult(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      publishedAt: json['publishedAt'] is String
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }
}

/// Provider for [YouTubeService].
final youtubeServiceProvider = Provider<YouTubeService>((ref) {
  throw UnimplementedError('Override in main.dart with CloudFunctionsYouTubeService.');
});
