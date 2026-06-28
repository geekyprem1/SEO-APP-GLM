import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/generated_hashtag.dart';
import '../repository/hashtag_repository.dart';

typedef HashtagState = AsyncValue<GeneratedHashtag>;

class HashtagNotifier extends StateNotifier<HashtagState> {
  HashtagNotifier(this._repository) : super(const AsyncValue.loading());

  final HashtagRepository _repository;
  GeneratedHashtag? _lastResult;
  GeneratedHashtag? get lastResult => _lastResult;

  Future<void> generate({required String topic}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.generate(topic: topic);
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

final hashtagProvider =
    StateNotifierProvider<HashtagNotifier, HashtagState>((ref) {
  return HashtagNotifier(ref.watch(hashtagRepositoryProvider));
});
