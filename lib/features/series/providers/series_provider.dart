import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_series.dart';
import '../repository/series_repository.dart';

typedef SeriesState = AsyncValue<GeneratedSeries>;

class SeriesNotifier extends StateNotifier<SeriesState> {
  SeriesNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  final SeriesRepository _repository;
  final Ref _ref;
  GeneratedSeries? _last;

  Future<void> generate({
    required String topic,
    required String language,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.generate(
        topic: topic,
        language: language,
        format: _ref.read(selectedFormatProvider),
      );
      _last = result;
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveToHistory() async {
    final result = _last;
    if (result == null) return false;
    try {
      await _repository.saveToHistory(result);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final seriesProvider = StateNotifierProvider<SeriesNotifier, SeriesState>((ref) {
  return SeriesNotifier(ref.watch(seriesRepositoryProvider), ref);
});
