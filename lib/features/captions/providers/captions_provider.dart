import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_captions.dart';
import '../repository/captions_repository.dart';

typedef CaptionsState = AsyncValue<GeneratedCaptions>;

class CaptionsNotifier extends StateNotifier<CaptionsState> {
  CaptionsNotifier(this._repository, this._ref)
      : super(const AsyncValue.loading());

  final CaptionsRepository _repository;
  final Ref _ref;

  GeneratedCaptions? _lastResult;

  Future<void> generate({
    required String topic,
    required String language,
    String? context,
  }) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(
        topic: topic,
        language: language,
        context: context,
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

final captionsProvider =
    StateNotifierProvider<CaptionsNotifier, CaptionsState>((ref) {
  return CaptionsNotifier(ref.watch(captionsRepositoryProvider), ref);
});
