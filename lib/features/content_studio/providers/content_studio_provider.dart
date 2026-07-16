import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_duration.dart';
import '../../../shared/models/content_format.dart';
import '../../../shared/models/tone.dart';
import '../models/content_package.dart';
import '../repository/content_studio_repository.dart';

typedef ContentStudioState = AsyncValue<ContentPackage>;

/// Manages generation of an all-in-one [ContentPackage].
///
/// Follows the same shape as the other generators: [AsyncValue.loading] before
/// any generation, [AsyncValue.data] on success, [AsyncValue.error] on failure.
/// The `hasGenerated` flag on the screen distinguishes the initial idle state
/// from a real loading state.
class ContentStudioNotifier extends StateNotifier<ContentStudioState> {
  ContentStudioNotifier(this._repository) : super(const AsyncValue.loading());

  final ContentStudioRepository _repository;

  ContentPackage? _lastResult;
  ContentPackage? get lastResult => _lastResult;

  Future<void> generate({
    required String topic,
    required ContentFormat format,
    required String language,
    required Tone tone,
    required ContentDuration duration,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.generate(
        topic: topic,
        format: format,
        language: language,
        tone: tone,
        duration: duration,
      );
      _lastResult = result;
      state = AsyncValue.data(result);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Persists the given (possibly edited) [package] to History.
  Future<bool> saveToHistory(ContentPackage package) async {
    try {
      await _repository.saveToHistory(package);
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

final contentStudioProvider =
    StateNotifierProvider<ContentStudioNotifier, ContentStudioState>((ref) {
  return ContentStudioNotifier(ref.watch(contentStudioRepositoryProvider));
});
