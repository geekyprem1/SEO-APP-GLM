import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/result_actions_bar.dart';
import '../../../core/widgets/common/shimmer_loading.dart';
import '../../../core/widgets/common/success_reveal.dart';

/// A reusable widget that displays a list of generated string items
/// with Copy/Share/Save actions. Used by Hashtag, Viral Ideas, Trending.
class GeneratedListResult extends ConsumerWidget {
  const GeneratedListResult({
    super.key,
    required this.state,
    required this.shareText,
    required this.onSave,
    required this.onRetry,
    required this.hasGenerated,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.numbered = true,
  });

  /// The async state holding the list of strings.
  final AsyncValue<List<String>> state;

  /// Text used for Copy/Share.
  final String Function() shareText;

  /// Save callback.
  final Future<bool> Function()? onSave;

  /// Retry callback.
  final VoidCallback onRetry;

  /// Whether generation has been triggered (controls empty state).
  final bool hasGenerated;

  /// Empty state configuration.
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  /// Whether to number the items.
  final bool numbered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasGenerated) {
      return _EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 8, itemHeight: 48),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: onRetry,
      ),
      data: (items) => SuccessReveal(child: _buildList(context, items)),
    );
  }

  Widget _buildList(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: shareText(),
          onSave: onSave,
        ),
        const SizedBox(height: AppSizes.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final item = items[index];
            return AppCard(
              child: Row(
                children: [
                  if (numbered) ...[
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm + 4),
                  ],
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          },
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryDark),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.sm),
            Text(subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
