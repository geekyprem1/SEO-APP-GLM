import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_hook.dart';
import '../repository/hook_repository.dart';

typedef HookState = AsyncValue<GeneratedHook>;

class HookNotifier extends StateNotifier<HookState> {
  HookNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  final HookRepository _repository;
  final Ref _ref;

  GeneratedHook? _lastResult;
  GeneratedHook? get lastResult => _lastResult;

  Future<void> generate({
    required String topic,
    required String language,
  }) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(
        topic: topic,
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
}

final hookProvider = StateNotifierProvider<HookNotifier, HookState>((ref) {
  return HookNotifier(ref.watch(hookRepositoryProvider), ref);
});
