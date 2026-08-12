import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Why the Pro teaser was opened — controls body copy only (no purchase).
enum ProUpgradeReason {
  /// User hit the free daily quota.
  quotaHit,

  /// Opened from Profile / home plan strip to explore Pro.
  explore,
}

/// Shows the Pro "coming soon" dialog.
Future<void> showProUpgradeDialog(
  BuildContext context, {
  ProUpgradeReason reason = ProUpgradeReason.quotaHit,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ProUpgradeDialog(reason: reason),
  );
}

/// Teaser shown when a free user hits their daily limit, or from Profile.
///
/// Billing is NOT live yet — no price and no purchase action.
class ProUpgradeDialog extends StatelessWidget {
  const ProUpgradeDialog({
    super.key,
    this.reason = ProUpgradeReason.quotaHit,
  });

  final ProUpgradeReason reason;

  static const _benefits = [
    '50 generations per feature daily',
    'All AI features unlocked',
    'Video + Shorts modes',
    'Priority generation',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = reason == ProUpgradeReason.quotaHit
        ? "You've used today's free generation for this feature. "
            'Pro will unlock much more — stay tuned.'
        : 'Pro unlocks higher daily limits across every AI tool. '
            'Billing is not live yet — stay tuned.';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Pro is coming soon',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ..._benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(b, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Text(
                  'Coming soon',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
