import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_cta.dart';
import '../repository/cta_repository.dart';

typedef CtaState = AsyncValue<GeneratedCta>;

class CtaNotifier extends StateNotifier<CtaState> {
  CtaNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  final CtaRepository _repository;
  final Ref _ref;
  GeneratedCta? _last;

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

final ctaProvider = StateNotifierProvider<CtaNotifier, CtaState>((ref) {
  return CtaNotifier(ref.watch(ctaRepositoryProvider), ref);
});
