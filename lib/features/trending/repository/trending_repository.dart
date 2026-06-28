import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../../../shared/models/content_format.dart';
import '../models/trending_topics.dart';
import 'trending_prompt_builder.dart';

abstract class TrendingRepository {
  Future<TrendingTopics> generate({
    required String category,
    required String country,
    required String language,
    ContentFormat format,
  });
  Future<void> saveToHistory(TrendingTopics topics);
}

class TrendingRepositoryImpl implements TrendingRepository {
  TrendingRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<TrendingTopics> generate({
    required String category,
    required String country,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) async {
    try {
      final request = TrendingPromptBuilder.build(
        category: category,
        country: country,
        language: language,
        format: format,
      );
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final topics = TrendingTopics.fromAiJson(
        id: const Uuid().v4(),
        category: category,
        country: country,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (topics.topics.isEmpty) {
        throw _errorHandler.convert(
          Exception('No topics were generated. Please try again.'),
          StackTrace.current,
        );
      }

      return topics;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(TrendingTopics topics) async {
    try {
      final item = HistoryItem(
        id: topics.id,
        type: HistoryType.trending,
        displayTitle: '${topics.category} • ${topics.country}',
        data: topics.toJson(),
        createdAt: topics.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final trendingRepositoryProvider = Provider<TrendingRepository>((ref) {
  return TrendingRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
