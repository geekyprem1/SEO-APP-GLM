import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_description.dart';
import 'description_prompt_builder.dart';

abstract class DescriptionRepository {
  Future<GeneratedDescription> generate({required String topic});
  Future<void> saveToHistory(GeneratedDescription description);
}

class DescriptionRepositoryImpl implements DescriptionRepository {
  DescriptionRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedDescription> generate({required String topic}) async {
    try {
      final request = DescriptionPromptBuilder.build(topic: topic);
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final description = GeneratedDescription.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (description.description.isEmpty) {
        throw _errorHandler.convert(
          Exception('No description was generated. Please try again.'),
          StackTrace.current,
        );
      }

      return description;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedDescription description) async {
    try {
      final item = HistoryItem(
        id: description.id,
        type: HistoryType.description,
        displayTitle: description.topic,
        data: description.toJson(),
        createdAt: description.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final descriptionRepositoryProvider = Provider<DescriptionRepository>((ref) {
  return DescriptionRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
