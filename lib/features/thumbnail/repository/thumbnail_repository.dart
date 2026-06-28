import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ai/cloud_functions_image_service.dart';
import '../../../core/services/ai/image_generation_service.dart';
import '../../history/models/history_item.dart';
import '../../history/repository/history_repository.dart';
import '../models/generated_thumbnail.dart';
import 'thumbnail_prompt_builder.dart';

abstract class ThumbnailRepository {
  /// Generates a thumbnail image for the given inputs.
  Future<GeneratedThumbnail> generate({
    required String topic,
    required String category,
    required ThumbnailStyle style,
  });

  /// Saves a generated thumbnail to history.
  Future<void> saveToHistory(GeneratedThumbnail thumbnail);
}

class ThumbnailRepositoryImpl implements ThumbnailRepository {
  ThumbnailRepositoryImpl(
    this._imageService,
    this._historyRepository,
    this._errorHandler,
  );

  final ImageGenerationService _imageService;
  final HistoryRepository _historyRepository;
  final ErrorHandler _errorHandler;

  @override
  Future<GeneratedThumbnail> generate({
    required String topic,
    required String category,
    required ThumbnailStyle style,
  }) async {
    try {
      final request = ThumbnailPromptBuilder.build(
        topic: topic,
        category: category,
        style: style,
      );
      final result = await _imageService.generateImage(request: request);

      if (result.imageUrl.isEmpty) {
        throw _errorHandler.convert(
          Exception('No image was generated. Please try again.'),
          StackTrace.current,
        );
      }

      return GeneratedThumbnail.fromResult(
        id: const Uuid().v4(),
        topic: topic,
        category: category,
        style: style.label,
        imageUrl: result.imageUrl,
        createdAt: DateTime.now(),
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> saveToHistory(GeneratedThumbnail thumbnail) async {
    try {
      final item = HistoryItem(
        id: thumbnail.id,
        type: HistoryType.thumbnail,
        displayTitle: '${thumbnail.topic} (${thumbnail.style})',
        data: thumbnail.toJson(),
        createdAt: thumbnail.createdAt,
      );
      await _historyRepository.add(item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

final thumbnailRepositoryProvider = Provider<ThumbnailRepository>((ref) {
  return ThumbnailRepositoryImpl(
    ref.watch(imageGenerationServiceProvider),
    ref.watch(historyRepositoryProvider),
    ref.watch(errorHandlerProvider),
  );
});
