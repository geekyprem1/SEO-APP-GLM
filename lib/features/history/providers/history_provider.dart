import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_item.dart';
import '../repository/history_repository.dart';

/// State for the History screen: a list of [HistoryItem]s.
typedef HistoryState = AsyncValue<List<HistoryItem>>;

/// Notifier that manages the history list state.
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final HistoryRepository _repository;

  /// Loads all history items from Hive.
  void _load() {
    state = AsyncValue.data(_repository.getAll());
  }

  /// Refreshes the list from storage.
  void refresh() {
    _load();
  }

  /// Deletes a single item by id and refreshes the list.
  Future<void> delete(String id) async {
    await _repository.delete(id);
    _load();
  }

  /// Clears all history and refreshes the list.
  Future<void> clearAll() async {
    await _repository.clearAll();
    _load();
  }
}

/// Provider for the History screen state.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});

/// Provider to fetch a single history item by id (for the detail screen).
final historyItemByIdProvider =
    FutureProvider.family<HistoryItem?, String>((ref, id) async {
  final repository = ref.watch(historyRepositoryProvider);
  return repository.getById(id);
});
