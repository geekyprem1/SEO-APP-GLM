import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../models/generated_description.dart';
import '../repository/description_repository.dart';

typedef DescriptionState = AsyncValue<GeneratedDescription>;

class DescriptionNotifier extends StateNotifier<DescriptionState> {
  DescriptionNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  final DescriptionRepository _repository;
  final Ref _ref;
  GeneratedDescription? _lastResult;
  GeneratedDescription? get lastResult => _lastResult;

  Future<void> generate({required String topic}) async {
    state = const AsyncValue.loading();
    try {
      final format = _ref.read(selectedFormatProvider);
      final result = await _repository.generate(topic: topic, format: format);
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

final descriptionProvider =
    StateNotifierProvider<DescriptionNotifier, DescriptionState>((ref) {
  return DescriptionNotifier(ref.watch(descriptionRepositoryProvider), ref);
});
