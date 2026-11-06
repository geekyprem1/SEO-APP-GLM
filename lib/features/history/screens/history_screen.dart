import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/common/empty_state.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/shimmer_loading.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';
import '../repository/history_repository.dart';
import '../widgets/history_tile.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text(
          'This will permanently delete all saved generations. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(historyProvider.notifier).clearAll();
        if (context.mounted) {
          UiUtils.showSuccessSnackBar(context, 'History cleared');
        }
      } catch (_) {
        if (context.mounted) {
          UiUtils.showErrorSnackBar(
            context,
            'Could not clear history. Please try again.',
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    HistoryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this item?'),
        content: Text('"${item.displayTitle}" will be removed from history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(historyProvider.notifier).delete(item.id);
      // A cached detail entry would otherwise still resolve after deletion.
      ref.invalidate(historyItemByIdProvider(item.id));
      if (context.mounted) {
        UiUtils.showUndoSnackBar(
          context,
          'Item deleted',
          onUndo: () => _undoDelete(ref, item),
        );
      }
    } catch (_) {
      if (context.mounted) {
        UiUtils.showErrorSnackBar(
          context,
          'Could not delete. Please try again.',
        );
      }
    }
  }

  /// Restores an item deleted from the snackbar's Undo action.
  Future<void> _undoDelete(WidgetRef ref, HistoryItem item) async {
    try {
      await ref.read(historyRepositoryProvider).add(item);
      ref.invalidate(historyItemByIdProvider(item.id));
    } catch (_) {
      // Best-effort; the invalidate below still shows the true list state.
    }
    ref.invalidate(historyProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('History'),
        actions: [
          historyState.maybeWhen(
            data: (items) => items.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep_rounded),
                    onPressed: () => _confirmClearAll(context, ref),
                    tooltip: 'Clear All',
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: historyState.when(
          loading: () => const ShimmerList(itemCount: 8, itemHeight: 72),
          error: (error, _) => ErrorState(
            failure: error is Failure
                ? error
                : const UnknownFailure(),
            onRetry: () => ref.read(historyProvider.notifier).refresh(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.history_rounded,
                title: 'No History Yet',
                subtitle:
                    'Your saved generations will appear here. Use any feature and tap Save to build your history.',
              );
            }

            final hasMore = ref.watch(historyProvider.notifier).hasMore;
            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              itemCount: items.length + (hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return Center(
                    child: TextButton(
                      onPressed: () =>
                          ref.read(historyProvider.notifier).loadMore(),
                      child: const Text('Load more'),
                    ),
                  );
                }
                final item = items[index];
                return HistoryTile(
                  item: item,
                  onTap: () => context.push(
                    AppRoutes.historyDetailFor(item.id),
                  ),
                  onDelete: () => _confirmDelete(context, ref, item),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
