import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_constants.dart';
import '../../error/error_handler.dart';
import '../../error/exceptions.dart';
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

      final data = response.data as Map<String, dynamic>;
      _checkError(data);
      return _parseVideo(data['video'] as Map<String, dynamic>);
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

      final data = response.data as Map<String, dynamic>;
      _checkError(data);
      return _parseChannel(data['channel'] as Map<String, dynamic>);
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

      final data = response.data as Map<String, dynamic>;
      _checkError(data);
      final items = data['results'] as List<dynamic>? ?? [];
      return items
          .map((e) => _parseSearchResult(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  void _checkError(Map<String, dynamic> data) {
    final error = data['error'] as String?;
    if (error != null) {
      final code = data['errorCode'] as String? ?? 'UNKNOWN';
      throw ApiException(error, code: code);
    }
  }

  YouTubeVideo _parseVideo(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['videoId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      channelId: json['channelId'] as String?,
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      viewCount: json['viewCount'] as int?,
      likeCount: json['likeCount'] as int?,
      commentCount: json['commentCount'] as int?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }

  YouTubeChannel _parseChannel(Map<String, dynamic> json) {
    return YouTubeChannel(
      channelId: json['channelId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      subscriberCount: json['subscriberCount'] as int?,
      videoCount: json['videoCount'] as int?,
      viewCount: json['viewCount'] as int?,
    );
  }

  YouTubeSearchResult _parseSearchResult(Map<String, dynamic> json) {
    return YouTubeSearchResult(
      videoId: json['videoId'] as String,
      title: json['title'] as String? ?? '',
      channelTitle: json['channelTitle'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }
}

/// Provider for [YouTubeService].
final youtubeServiceProvider = Provider<YouTubeService>((ref) {
  throw UnimplementedError('Override in main.dart with CloudFunctionsYouTubeService.');
});
