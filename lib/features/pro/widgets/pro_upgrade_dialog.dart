import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../shared/models/user_plan.dart';

/// Shows the Pro upgrade paywall dialog.
Future<void> showProUpgradeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ProUpgradeDialog(),
  );
}

/// Paywall popup shown when a free user hits their daily limit, or from Profile.
class ProUpgradeDialog extends StatelessWidget {
  const ProUpgradeDialog({super.key});

  static const _benefits = [
    '50 generations per feature daily',
    'All 8 AI features',
    'Video + Shorts modes',
    'Priority generation',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium_rounded,
                    size: 40, color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Upgrade to Pro',
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.xs),
            Text(
              'You\'ve used your free generation for today.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ..._benefits.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(child: Text(b, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                )),
            const SizedBox(height: AppSizes.md),
            Text(
              '₹$kProPriceRupees / month',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                UiUtils.showSuccessSnackBar(
                  context,
                  'Payments coming soon via Play Store.',
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
              ),
              child: const Text('Upgrade Now'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe later'),
            ),
          ],
        ),
      ),
    );
  }
}
