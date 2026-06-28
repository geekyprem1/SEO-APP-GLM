import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/seo_analysis.dart';
import '../repository/seo_repository.dart';

typedef SeoState = AsyncValue<SeoAnalysis>;

class SeoNotifier extends StateNotifier<SeoState> {
  SeoNotifier(this._repository) : super(const AsyncValue.loading());

  final SeoRepository _repository;
  SeoAnalysis? _lastResult;
  SeoAnalysis? get lastResult => _lastResult;

  Future<void> analyze({required String videoUrl}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.analyze(videoUrl: videoUrl);
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

final seoProvider = StateNotifierProvider<SeoNotifier, SeoState>((ref) {
  return SeoNotifier(ref.watch(seoRepositoryProvider));
});
