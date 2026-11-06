import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_constants.dart';
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

  /// How many items the current window requests from storage.
  int _limit = AppConstants.defaultPageSize;

  bool _hasMore = false;

  /// True when storage may hold more items than are currently loaded.
  bool get hasMore => _hasMore;

  /// Loads the current page window from storage.
  void _load() {
    final page = _repository.getPage(limit: _limit);
    _hasMore = page.length >= _limit;
    state = AsyncValue.data(page);
  }

  /// Refreshes the list from the first page.
  void refresh() {
    _limit = AppConstants.defaultPageSize;
    _load();
  }

  /// Loads the next page of history.
  void loadMore() {
    if (!_hasMore) return;
    _limit += AppConstants.defaultPageSize;
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
    refresh();
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
