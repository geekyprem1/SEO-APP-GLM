import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_series.dart';
import 'series_prompt_builder.dart';

abstract class SeriesRepository {
  Future<GeneratedSeries> generate({
    required String topic,
    required String language,
    ContentFormat format,
  });
  Future<void> saveToHistory(GeneratedSeries series);
}

class SeriesRepositoryImpl implements SeriesRepository {
  SeriesRepositoryImpl(this._ai, this._history, this._errors);

  final AiService _ai;
  final HistoryRepository _history;
  final ErrorHandler _errors;

  @override
  Future<GeneratedSeries> generate({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) async {
    try {
      final result = await _ai.generate(
        request: SeriesPromptBuilder.build(
          topic: topic,
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
      final series = GeneratedSeries.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );
      if (series.ideas.isEmpty) {
        throw _errors.convert(
          Exception('No series ideas were generated. Please try again.'),
          StackTrace.current,
        );
      }
      return series;
    } catch (e, st) {
      throw _errors.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedSeries series) async {
    try {
      await _history.add(HistoryItem(
        id: series.id,
        type: HistoryType.series,
        displayTitle: series.topic,
        data: series.toJson(),
        createdAt: series.createdAt,
      ));
    } catch (e, st) {
      throw _errors.convert(e, st);
    }
  }
}

final seriesRepositoryProvider = Provider<SeriesRepository>((ref) {
  return SeriesRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
