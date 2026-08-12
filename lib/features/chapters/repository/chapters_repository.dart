import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_chapters.dart';
import 'chapters_prompt_builder.dart';

abstract class ChaptersRepository {
  Future<GeneratedChapters> generate({
    required String topic,
    required String language,
    required String durationLabel,
    ContentFormat format,
  });

  Future<void> saveToHistory(GeneratedChapters chapters);
}

class ChaptersRepositoryImpl implements ChaptersRepository {
  ChaptersRepositoryImpl(
    this._aiService,
    this._historyRepository,
    this._errorHandler,
  );

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedChapters> generate({
    required String topic,
    required String language,
    required String durationLabel,
    ContentFormat format = ContentFormat.longForm,
  }) async {
    try {
      final request = ChaptersPromptBuilder.build(
        topic: topic,
        language: language,
        durationLabel: durationLabel,
        format: format,
      );
      final result = await _aiService.generate(request: request);
      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final chapters = GeneratedChapters.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        language: language,
        durationLabel: durationLabel,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (chapters.chapters.isEmpty) {
        throw _errorHandler.convert(
          Exception('No chapters were generated. Please try again.'),
          StackTrace.current,
        );
      }
      return chapters;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedChapters chapters) async {
    try {
      await _historyRepository.add(
        HistoryItem(
          id: chapters.id,
          type: HistoryType.chapters,
          displayTitle: chapters.topic,
          data: chapters.toJson(),
          createdAt: chapters.createdAt,
        ),
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final chaptersRepositoryProvider = Provider<ChaptersRepository>((ref) {
  return ChaptersRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
