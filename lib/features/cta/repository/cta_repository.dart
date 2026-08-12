import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_cta.dart';
import 'cta_prompt_builder.dart';

abstract class CtaRepository {
  Future<GeneratedCta> generate({
    required String topic,
    required String language,
    ContentFormat format,
  });
  Future<void> saveToHistory(GeneratedCta cta);
}

class CtaRepositoryImpl implements CtaRepository {
  CtaRepositoryImpl(this._ai, this._history, this._errors);

  final AiService _ai;
  final HistoryRepository _history;
  final ErrorHandler _errors;

  @override
  Future<GeneratedCta> generate({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) async {
    try {
      final result = await _ai.generate(
        request: CtaPromptBuilder.build(
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
      final cta = GeneratedCta.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );
      if (cta.ctas.isEmpty) {
        throw _errors.convert(
          Exception('No CTAs were generated. Please try again.'),
          StackTrace.current,
        );
      }
      return cta;
    } catch (e, st) {
      throw _errors.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedCta cta) async {
    try {
      await _history.add(HistoryItem(
        id: cta.id,
        type: HistoryType.cta,
        displayTitle: cta.topic,
        data: cta.toJson(),
        createdAt: cta.createdAt,
      ));
    } catch (e, st) {
      throw _errors.convert(e, st);
    }
  }
}

final ctaRepositoryProvider = Provider<CtaRepository>((ref) {
  return CtaRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
