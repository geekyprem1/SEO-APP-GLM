import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../../../shared/models/content_format.dart';
import '../models/generated_content.dart';
import 'content_prompt_builder.dart';

abstract class ContentRepository {
  Future<GeneratedContent> generate({required String topic, required String language, ContentFormat format});
  Future<void> saveToHistory(GeneratedContent content);
}

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedContent> generate({required String topic, required String language, ContentFormat format = ContentFormat.shorts}) async {
    try {
      final request = ContentPromptBuilder.build(topic: topic, language: language, format: format);
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final content = GeneratedContent.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (content.hook.isEmpty && content.mainContent.isEmpty) {
        throw _errorHandler.convert(
          Exception('No content was generated. Please try again.'),
          StackTrace.current,
        );
      }

      return content;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedContent content) async {
    try {
      final item = HistoryItem(
        id: content.id,
        type: HistoryType.content,
        displayTitle: content.topic,
        data: content.toJson(),
        createdAt: content.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
