import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_competitor_titles.dart';
import '../repository/competitor_repository.dart';

typedef CompetitorState = AsyncValue<GeneratedCompetitorTitles>;

class CompetitorNotifier extends StateNotifier<CompetitorState> {
  CompetitorNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  final CompetitorRepository _repository;
  final Ref _ref;
  GeneratedCompetitorTitles? _last;

  Future<void> generate({
    required String sourceTitle,
    required String language,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.generate(
        sourceTitle: sourceTitle,
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

final competitorProvider =
    StateNotifierProvider<CompetitorNotifier, CompetitorState>((ref) {
  return CompetitorNotifier(ref.watch(competitorRepositoryProvider), ref);
});
