import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_thumbnail.dart';
import '../repository/thumbnail_repository.dart';

typedef ThumbnailState = AsyncValue<GeneratedThumbnail>;

class ThumbnailNotifier extends StateNotifier<ThumbnailState> {
  ThumbnailNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  final ThumbnailRepository _repository;
  final Ref _ref;
  GeneratedThumbnail? _lastResult;
  GeneratedThumbnail? get lastResult => _lastResult;

  Future<void> generate({
    required String topic,
    required String category,
    required ThumbnailStyle style,
  }) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(
        topic: topic,
        category: category,
        style: style,
        format: format,
      );
      _lastResult = result;
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<bool> saveToHistory() async {
    final result = _lastResult;
    if (result == null) return false;
    try {
      await _repository.saveToHistory(result);
      return true;
    } catch (_) {
      return false;
    }
  }

  void reset() {
    _lastResult = null;
    state = const AsyncValue.loading();
  }
}

final thumbnailProvider =
    StateNotifierProvider<ThumbnailNotifier, ThumbnailState>((ref) {
  return ThumbnailNotifier(ref.watch(thumbnailRepositoryProvider), ref);
});
