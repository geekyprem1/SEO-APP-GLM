import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/trending_topics.dart';
import '../repository/trending_repository.dart';

typedef TrendingState = AsyncValue<TrendingTopics>;

class TrendingNotifier extends StateNotifier<TrendingState> {
  TrendingNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  final TrendingRepository _repository;
  final Ref _ref;
  TrendingTopics? _lastResult;
  TrendingTopics? get lastResult => _lastResult;

  Future<void> generate({
    required String category,
    required String country,
    required String language,
  }) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(
        category: category,
        country: country,
        language: language,
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

final trendingProvider =
    StateNotifierProvider<TrendingNotifier, TrendingState>((ref) {
  return TrendingNotifier(ref.watch(trendingRepositoryProvider), ref);
});
