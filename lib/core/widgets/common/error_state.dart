import 'package:flutter/material.dart';

import '../../constants/app_sizes.dart';
import '../../error/failures.dart';
import '../../../features/pro/widgets/pro_upgrade_dialog.dart';

/// A reusable error state with a friendly message and retry button.
///
/// For [QuotaExceededFailure] it shows a Pro upgrade prompt instead of Retry.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.failure,
    this.onRetry,
  });

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isQuota = failure is QuotaExceededFailure;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isQuota ? Icons.workspace_premium_rounded : _iconFor(failure),
              size: 64,
              color: isQuota
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              failure.message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (isQuota) ...[
              const SizedBox(height: AppSizes.lg),
              FilledButton.icon(
                onPressed: () => showProUpgradeDialog(context),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Upgrade to Pro'),
              ),
            ] else if (onRetry != null) ...[
              const SizedBox(height: AppSizes.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(Failure failure) {
    return switch (failure) {
      NetworkFailure() => Icons.wifi_off_rounded,
      TimeoutFailure() => Icons.hourglass_empty_rounded,
      QuotaExceededFailure() => Icons.block_rounded,
      BudgetExceededFailure() => Icons.account_balance_wallet_outlined,
      RateLimitFailure() => Icons.timer_outlined,
      ValidationFailure() => Icons.error_outline_rounded,
      _ => Icons.error_outline_rounded,
    };
  }
}
