import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/error_handler.dart';
import '../models/history_item.dart';

/// Abstract history repository interface.
abstract class HistoryRepository {
  /// Returns all history items sorted by createdAt descending.
  List<HistoryItem> getAll();

  /// Returns a single item by id, or null.
  HistoryItem? getById(String id);

  /// Adds an item. Evicts oldest if over [AppConstants.maxHistoryItems].
  Future<void> add(HistoryItem item);

  /// Deletes an item by id.
  Future<void> delete(String id);

  /// Clears all history.
  Future<void> clearAll();
}

/// Hive implementation of [HistoryRepository].
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._box, this._errorHandler);

  final Box<HistoryItem> _box;
  final ErrorHandler _errorHandler;

  @override
  List<HistoryItem> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  HistoryItem? getById(String id) {
    try {
      return _box.values.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(HistoryItem item) async {
    try {
      // Evict oldest entries if at capacity.
      if (_box.length >= AppConstants.maxHistoryItems) {
        final sorted = getAll().reversed.toList(); // oldest first
        final toRemove = sorted.take(_box.length - AppConstants.maxHistoryItems + 1);
        for (final old in toRemove) {
          await old.delete();
        }
      }
      await _box.put(item.id, item);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

/// Provider for the [HistoryRepository].
/// Requires Hive to be initialized and the history box opened in main.dart.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw UnimplementedError('Override in main.dart with an opened Hive box.');
});
