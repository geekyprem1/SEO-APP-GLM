import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_format.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_hook.dart';
import 'hook_prompt_builder.dart';

abstract class HookRepository {
  Future<GeneratedHook> generate({
    required String topic,
    required String language,
    ContentFormat format,
  });

  Future<void> saveToHistory(GeneratedHook hook);
}

class HookRepositoryImpl implements HookRepository {
  HookRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedHook> generate({
    required String topic,
    required String language,
    ContentFormat format = ContentFormat.shorts,
  }) async {
    try {
      final request = HookPromptBuilder.build(
        topic: topic,
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

      final hook = GeneratedHook.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (hook.hooks.isEmpty) {
        throw _errorHandler.convert(
          Exception('No hooks were generated. Please try again.'),
          StackTrace.current,
        );
      }

      return hook;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedHook hook) async {
    try {
      await _historyRepository.add(
        HistoryItem(
          id: hook.id,
          type: HistoryType.hook,
          displayTitle: hook.topic,
          data: hook.toJson(),
          createdAt: hook.createdAt,
        ),
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final hookRepositoryProvider = Provider<HookRepository>((ref) {
  return HookRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
