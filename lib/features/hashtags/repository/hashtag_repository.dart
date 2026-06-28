import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_hashtag.dart';
import 'hashtag_prompt_builder.dart';

abstract class HashtagRepository {
  Future<GeneratedHashtag> generate({required String topic});
  Future<void> saveToHistory(GeneratedHashtag hashtag);
}

class HashtagRepositoryImpl implements HashtagRepository {
  HashtagRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedHashtag> generate({required String topic}) async {
    try {
      final request = HashtagPromptBuilder.build(topic: topic);
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final hashtag = GeneratedHashtag.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (hashtag.hashtags.isEmpty) {
        throw _errorHandler.convert(
          Exception('No hashtags were generated. Please try again.'),
          StackTrace.current,
        );
      }

      return hashtag;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedHashtag hashtag) async {
    try {
      final item = HistoryItem(
        id: hashtag.id,
        type: HistoryType.hashtag,
        displayTitle: hashtag.topic,
        data: hashtag.toJson(),
        createdAt: hashtag.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final hashtagRepositoryProvider = Provider<HashtagRepository>((ref) {
  return HashtagRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
