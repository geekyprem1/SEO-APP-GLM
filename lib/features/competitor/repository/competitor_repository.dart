import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_competitor_titles.dart';
import 'competitor_prompt_builder.dart';

abstract class CompetitorRepository {
  Future<GeneratedCompetitorTitles> generate({
    required String sourceTitle,
    required String language,
    ContentFormat format,
  });
  Future<void> saveToHistory(GeneratedCompetitorTitles result);
}

class CompetitorRepositoryImpl implements CompetitorRepository {
  CompetitorRepositoryImpl(this._ai, this._history, this._errors);

  final AiService _ai;
  final HistoryRepository _history;
  final ErrorHandler _errors;

  @override
  Future<GeneratedCompetitorTitles> generate({
    required String sourceTitle,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) async {
    try {
      final result = await _ai.generate(
        request: CompetitorPromptBuilder.build(
          sourceTitle: sourceTitle,
          language: language,
          format: format,
        ),
      );
      if (result.json == null) {
        throw _errors.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }
      final titles = GeneratedCompetitorTitles.fromAiJson(
        id: const Uuid().v4(),
        sourceTitle: sourceTitle,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );
      if (titles.titles.isEmpty) {
        throw _errors.convert(
          Exception('No titles were generated. Please try again.'),
          StackTrace.current,
        );
      }
      return titles;
    } catch (e, st) {
      throw _errors.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedCompetitorTitles result) async {
    try {
      await _history.add(HistoryItem(
        id: result.id,
        type: HistoryType.competitor,
        displayTitle: result.sourceTitle,
        data: result.toJson(),
        createdAt: result.createdAt,
      ));
    } catch (e, st) {
      throw _errors.convert(e, st);
    }
  }
}

final competitorRepositoryProvider = Provider<CompetitorRepository>((ref) {
  return CompetitorRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
