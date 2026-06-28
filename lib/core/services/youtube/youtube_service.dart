import 'youtube_models.dart';

/// Abstract YouTube service interface.
///
/// Wraps YouTube Data API v3 (accessed through Cloud Functions — API key
/// stays server-side). Used by the SEO Analysis feature and reserved for
/// future features (competitor analysis, keyword explorer, best upload time).
///
/// Swapping the data source requires only implementing this interface.
abstract class YouTubeService {
  /// Fetches full metadata for a single video by URL or ID.
  Future<YouTubeVideo> fetchVideoMetadata({required String videoUrlOrId});

  /// Fetches channel information by channel ID.
  Future<YouTubeChannel> fetchChannelInfo({required String channelId});

  /// Searches YouTube for videos matching [query].
  Future<List<YouTubeSearchResult>> search({
    required String query,
    int maxResults = 10,
  });
}
