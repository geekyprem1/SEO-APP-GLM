import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/viral_ideas.dart';
import '../repository/viral_ideas_repository.dart';

typedef ViralIdeasState = AsyncValue<ViralIdeas>;

class ViralIdeasNotifier extends StateNotifier<ViralIdeasState> {
  ViralIdeasNotifier(this._repository) : super(const AsyncValue.loading());

  final ViralIdeasRepository _repository;
  ViralIdeas? _lastResult;
  ViralIdeas? get lastResult => _lastResult;

  Future<void> generate({required String category, required String language}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.generate(category: category, language: language);
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

final viralIdeasProvider =
    StateNotifierProvider<ViralIdeasNotifier, ViralIdeasState>((ref) {
  return ViralIdeasNotifier(ref.watch(viralIdeasRepositoryProvider));
});
