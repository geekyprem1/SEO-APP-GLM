import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/ai_service.dart';
import '../../../core/services/ai/cloud_functions_ai_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/viral_ideas.dart';
import 'viral_ideas_prompt_builder.dart';

abstract class ViralIdeasRepository {
  Future<ViralIdeas> generate({required String category, required String language});
  Future<void> saveToHistory(ViralIdeas ideas);
}

class ViralIdeasRepositoryImpl implements ViralIdeasRepository {
  ViralIdeasRepositoryImpl(this._aiService, this._historyRepository, this._errorHandler);

  final AiService _aiService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<ViralIdeas> generate({required String category, required String language}) async {
    try {
      final request = ViralIdeasPromptBuilder.build(category: category, language: language);
      final result = await _aiService.generate(request: request);

      if (result.json == null) {
        throw _errorHandler.convert(
          Exception('AI did not return structured JSON. Please try again.'),
          StackTrace.current,
        );
      }

      final ideas = ViralIdeas.fromAiJson(
        id: const Uuid().v4(),
        category: category,
        language: language,
        json: result.json!,
        createdAt: DateTime.now(),
      );

      if (ideas.ideas.isEmpty) {
        throw _errorHandler.convert(
          Exception('No ideas were generated. Please try again.'),
          StackTrace.current,
        );
      }

      return ideas;
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(ViralIdeas ideas) async {
    try {
      final item = HistoryItem(
        id: ideas.id,
        type: HistoryType.viralIdeas,
        displayTitle: '${ideas.category} (${ideas.language})',
        data: ideas.toJson(),
        createdAt: ideas.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final viralIdeasRepositoryProvider = Provider<ViralIdeasRepository>((ref) {
  return ViralIdeasRepositoryImpl(
    ref.watch(aiServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
