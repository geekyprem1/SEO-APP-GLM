import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../../shared/models/content_duration.dart';
import '../../../shared/models/content_format.dart';
import '../../../shared/models/tone.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/content_package.dart';
import 'content_studio_prompt_builder.dart';

abstract class ContentStudioRepository {
  Future<ContentPackage> generate({
    required String topic,
    required ContentFormat format,
    required String language,
    required Tone tone,
    required ContentDuration duration,
  });

  Future<void> saveToHistory(ContentPackage package);
}

class ContentStudioRepositoryImpl implements ContentStudioRepository {
  ContentStudioRepositoryImpl(
    this._aiService,
    this._historyRepository,
    this._errorHandler,
  );

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<ContentPackage> generate({
    required String topic,
    required ContentFormat format,
    required String language,
    required Tone tone,
    required ContentDuration duration,
  }) async {
    try {
      final request = ContentStudioPromptBuilder.build(
        topic: topic,
        format: format,
        language: language,
        tone: tone,
        duration: duration,
      );
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final package = ContentPackage.fromAiJson(
        id: const Uuid().v4(),
        topic: topic,
        format: format,
        language: language,
        tone: tone.label,
        duration: duration.label,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (package.isEmpty) {
        throw _errorHandler.convert(
          Exception('No content was generated. Please try again.'),
          StackTrace.current,
        );
      }

      return package;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(ContentPackage package) async {
    try {
      final item = HistoryItem(
        id: package.id,
        type: HistoryType.contentStudio,
        displayTitle: package.topic,
        data: package.toJson(),
        createdAt: package.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final contentStudioRepositoryProvider = Provider<ContentStudioRepository>((ref) {
  return ContentStudioRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
