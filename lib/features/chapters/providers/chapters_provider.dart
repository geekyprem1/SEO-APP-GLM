import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_chapters.dart';
import '../repository/chapters_repository.dart';

typedef ChaptersState = AsyncValue<GeneratedChapters>;

class ChaptersNotifier extends StateNotifier<ChaptersState> {
  ChaptersNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  final ChaptersRepository _repository;
  final Ref _ref;

  GeneratedChapters? _lastResult;

  Future<void> generate({
    required String topic,
    required String language,
    required String durationLabel,
  }) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(
        topic: topic,
        language: language,
        durationLabel: durationLabel,
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
}

final chaptersProvider =
    StateNotifierProvider<ChaptersNotifier, ChaptersState>((ref) {
  return ChaptersNotifier(ref.watch(chaptersRepositoryProvider), ref);
});
