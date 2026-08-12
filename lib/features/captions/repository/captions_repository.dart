import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_captions.dart';
import 'captions_prompt_builder.dart';

abstract class CaptionsRepository {
  Future<GeneratedCaptions> generate({
    required String topic,
    required String language,
    String? context,
    ContentFormat format,
  });

  Future<void> saveToHistory(GeneratedCaptions captions);
}

class CaptionsRepositoryImpl implements CaptionsRepository {
  CaptionsRepositoryImpl(
    this._aiService,
    this._historyRepository,
    this._errorHandler,
  );

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedCaptions> generate({
    required String topic,
    required String language,
    String? context,
    ContentFormat format = ContentFormat.shorts,
  }) async {
    try {
      final request = CaptionsPromptBuilder.build(
        topic: topic,
        language: language,
        context: context,
        format: format,
      );
      final result = await _aiService.generate(request: request);
      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final captions = GeneratedCaptions.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (captions.lines.isEmpty) {
        throw _errorHandler.convert(
          Exception('No captions were generated. Please try again.'),
          StackTrace.current,
        );
      }
      return captions;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedCaptions captions) async {
    try {
      await _historyRepository.add(
        HistoryItem(
          id: captions.id,
          type: HistoryType.captions,
          displayTitle: captions.topic,
          data: captions.toJson(),
          createdAt: captions.createdAt,
        ),
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final captionsRepositoryProvider = Provider<CaptionsRepository>((ref) {
  return CaptionsRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
