import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_title.dart';
import 'title_prompt_builder.dart';

/// Abstract title repository interface.
abstract class TitleRepository {
  /// Generates 10 SEO-friendly titles for the given topic + language.
  Future<GeneratedTitle> generate({
    required String topic,
    required String language,
  });

  /// Saves a generated title to history.
  Future<void> saveToHistory(GeneratedTitle title);
}

/// Implementation of [TitleRepository].
///
/// Calls the [AiService] with a feature-specific prompt, maps the raw AI
/// result to a [GeneratedTitle], and can persist to history.
class TitleRepositoryImpl implements TitleRepository {
  TitleRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedTitle> generate({
    required String topic,
    required String language,
  }) async {
    try {
      final request = TitlePromptBuilder.build(topic: topic, language: language);
      final result = await _aiService.generate(request: request);

      // The AI should return JSON; if it didn't parse, throw.
      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final title = GeneratedTitle.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      // Safety: ensure we got titles.
      if (title.titles.isEmpty) {
        throw _errorHandler.convert(
          Exception('No titles were generated. Please try again.'),
          StackTrace.current,
        );
      }

      return title;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedTitle title) async {
    try {
      final item = HistoryItem(
        id: title.id,
        type: HistoryType.title,
        displayTitle: title.topic,
        data: title.toJson(),
        createdAt: title.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

/// Provider for [TitleRepository].
final titleRepositoryProvider = Provider<TitleRepository>((ref) {
  return TitleRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
