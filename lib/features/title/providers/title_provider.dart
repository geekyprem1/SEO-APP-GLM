import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/generated_title.dart';
import '../repository/title_repository.dart';

/// State for the Title Generator screen.
/// - AsyncValue.loading() → generating
/// - AsyncValue.data(GeneratedTitle) → result ready
/// - AsyncValue.error(Failure, _) → error with retry
typedef TitleState = AsyncValue<GeneratedTitle>;

/// Notifier that manages title generation state.
class TitleNotifier extends StateNotifier<TitleState> {
  TitleNotifier(this._repository) : super(const AsyncValue.loading());

  final TitleRepository _repository;

  /// The last successfully generated title (for Save action).
  GeneratedTitle? _lastResult;
  GeneratedTitle? get lastResult => _lastResult;

  /// Generates titles for the given topic + language.
  Future<void> generate({
    required String topic,
    required String language,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.generate(topic: topic, language: language);
      _lastResult = result;
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Saves the last generated title to history.
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

  /// Resets to initial state.
  void reset() {
    _lastResult = null;
    state = const AsyncValue.loading();
  }
}

/// Provider for the Title Generator screen state.
final titleProvider =
    StateNotifierProvider<TitleNotifier, TitleState>((ref) {
  return TitleNotifier(ref.watch(titleRepositoryProvider));
});
