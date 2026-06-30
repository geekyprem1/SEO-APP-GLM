import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

/// Shows the Pro "coming soon" dialog.
Future<void> showProUpgradeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ProUpgradeDialog(),
  );
}

/// Teaser shown when a free user hits their daily limit, or from Profile.
///
/// Billing is NOT live yet, so this intentionally shows NO price and NO
/// purchase action — only a "Coming soon" teaser. (Play Store policy: never
/// advertise a price or a buy button that cannot actually complete a purchase.)
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
            Text('Pro is coming soon',
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.xs),
            Text(
              "You've used your free generation for today. "
              'Pro will unlock a lot more — stay tuned.',
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
            const SizedBox(height: AppSizes.sm),
            // Neutral "coming soon" chip — NO price until billing is live.
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Text(
                  'Coming soon',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
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
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }
}
