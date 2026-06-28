import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_content.dart';
import '../repository/content_repository.dart';

typedef ContentState = AsyncValue<GeneratedContent>;

class ContentNotifier extends StateNotifier<ContentState> {
  ContentNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  final ContentRepository _repository;
  final Ref _ref;
  GeneratedContent? _lastResult;
  GeneratedContent? get lastResult => _lastResult;

  Future<void> generate({required String topic, required String language}) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(topic: topic, language: language, format: format);
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

final contentProvider =
    StateNotifierProvider<ContentNotifier, ContentState>((ref) {
  return ContentNotifier(ref.watch(contentRepositoryProvider), ref);
});
