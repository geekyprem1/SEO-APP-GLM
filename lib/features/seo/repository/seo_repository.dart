import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../core/services/youtube/cloud_functions_youtube_service.dart';
import '../../../core/services/youtube/youtube_service.dart';
import '../../../core/services/youtube/youtube_models.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/seo_analysis.dart';
import 'seo_prompt_builder.dart';

abstract class SeoRepository {
  /// Analyzes a YouTube video for SEO quality.
  /// Fetches metadata via YouTubeService, then runs AI analysis.
  Future<SeoAnalysis> analyze({required String videoUrl, ContentFormat format});

  /// Saves an analysis to history.
  Future<void> saveToHistory(SeoAnalysis analysis);
}

class SeoRepositoryImpl implements SeoRepository {
  SeoRepositoryImpl(
    this._youtubeService,
    this._aiService,
    this._historyRepository,
    this._errorHandler,
  );

  final YouTubeService _youtubeService;
  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<SeoAnalysis> analyze({required String videoUrl, ContentFormat format = ContentFormat.shorts}) async {
    try {
      // 1. Extract video ID from URL.
      final videoId = Validators.extractVideoId(videoUrl);
      if (videoId == null) {
        throw _errorHandler.convert(
          Exception('Invalid YouTube URL. Could not extract video ID.'),
          StackTrace.current,
        );
      }

      // 2. Fetch video metadata via YouTube Data API v3 (through Cloud Functions).
      final YouTubeVideo video =
          await _youtubeService.fetchVideoMetadata(videoUrlOrId: videoUrl);

      // 3. Build metadata map for the AI prompt.
      final metadata = <String, dynamic>{
        'title': video.title,
        'description': video.description,
        'channelTitle': video.channelTitle,
        'thumbnailUrl': video.thumbnailUrl,
        'tags': video.tags,
        'viewCount': video.viewCount,
        'likeCount': video.likeCount,
        'commentCount': video.commentCount,
      };

      // 4. Run AI analysis on the metadata.
      final request = SeoPromptBuilder.build(metadata: metadata, format: format);
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured analysis. Please try again.'),
          StackTrace.current,
        );
      }

      // 5. Combine metadata + AI analysis into SeoAnalysis model.
      final analysis = SeoAnalysis.fromAiJson(
        id: const Uuid().v4(),
        videoUrl: videoUrl,
        videoId: videoId,
        metadata: metadata,
        analysis: result.json!,
        createdAt: DateTime.now(),
      );

      return analysis;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(SeoAnalysis analysis) async {
    try {
      final item = HistoryItem(
        id: analysis.id,
        type: HistoryType.seo,
        displayTitle: analysis.title ?? analysis.videoId,
        data: analysis.toJson(),
        createdAt: analysis.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final seoRepositoryProvider = Provider<SeoRepository>((ref) {
  return SeoRepositoryImpl(
    ref.watch(youtubeServiceProvider),
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
