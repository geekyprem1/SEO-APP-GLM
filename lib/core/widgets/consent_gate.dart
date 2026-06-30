import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_constants.dart';
import '../constants/app_sizes.dart';
import '../services/privacy_consent.dart';

/// Wraps the app and shows a one-time consent prompt for analytics + crash
/// reporting the first time the app runs (when consent is undecided).
///
/// Rendered as an in-tree overlay (not a route dialog) so it stays put across
/// navigation until the user chooses, and never depends on a Navigator that
/// may not be mounted yet.
class ConsentGate extends ConsumerWidget {
  const ConsentGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(privacyConsentProvider);
    return Stack(
      children: [
        child,
        if (consent == null) const _ConsentSheet(),
      ],
    );
  }
}

class _ConsentSheet extends ConsumerWidget {
  const _ConsentSheet();

  Future<void> _openPrivacy(BuildContext context) async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(privacyConsentProvider.notifier);

    return Material(
      color: Colors.black54, // scrim
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(AppSizes.paddingLg),
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.shield_outlined,
                    size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: AppSizes.md),
                Text('Help improve Tubora',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'Allow Tubora to collect anonymous usage analytics and crash '
                  'reports so we can fix bugs and improve features. No personal '
                  'content is sold. You can change this anytime in Settings.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: () => _openPrivacy(context),
                  child: const Text('Read Privacy Policy'),
                ),
                const SizedBox(height: AppSizes.sm),
                FilledButton(
                  onPressed: () => notifier.setConsent(true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  ),
                  child: const Text('Allow'),
                ),
                const SizedBox(height: AppSizes.sm),
                OutlinedButton(
                  onPressed: () => notifier.setConsent(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  ),
                  child: const Text('No thanks'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
