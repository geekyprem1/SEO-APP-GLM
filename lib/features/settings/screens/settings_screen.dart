import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../history/providers/history_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
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
      await ref.read(historyProvider.notifier).clearAll();
      if (context.mounted) {
        UiUtils.showSuccessSnackBar(context, 'History cleared');
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      UiUtils.showErrorSnackBar(context, 'Could not open link');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          children: [
            // Appearance section
            _SectionHeader(title: 'Appearance'),
            const SizedBox(height: AppSizes.sm),
            AppCard(
              child: Column(
                children: [
                  _ThemeOption(
                    label: 'System Default',
                    icon: Icons.brightness_auto_rounded,
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                  const Divider(height: 1),
                  _ThemeOption(
                    label: 'Light Mode',
                    icon: Icons.light_mode_rounded,
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  const Divider(height: 1),
                  _ThemeOption(
                    label: 'Dark Mode',
                    icon: Icons.dark_mode_rounded,
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Data section
            _SectionHeader(title: 'Data'),
            const SizedBox(height: AppSizes.sm),
            AppCard(
              child: _SettingsTile(
                label: 'Clear All History',
                icon: Icons.delete_sweep_rounded,
                iconColor: theme.colorScheme.error,
                onTap: () => _confirmClearHistory(context, ref),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // About section
            _SectionHeader(title: 'About'),
            const SizedBox(height: AppSizes.sm),
            AppCard(
              child: Column(
                children: [
                  _SettingsTile(
                    label: 'App Version',
                    icon: Icons.info_outline_rounded,
                    trailing: Text(
                      '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    label: 'Privacy Policy',
                    icon: Icons.privacy_tip_rounded,
                    onTap: () =>
                        _launchUrl(context, AppConstants.privacyPolicyUrl),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    label: 'Terms of Service',
                    icon: Icons.description_rounded,
                    onTap: () => _launchUrl(context, AppConstants.termsUrl),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    label: 'Contact Us',
                    icon: Icons.mail_rounded,
                    onTap: () => _launchUrl(
                      context,
                      'mailto:${AppConstants.contactEmail}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Footer
            Center(
              child: Text(
                'ShortSEO AI v${AppConstants.appVersion}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Center(
              child: Text(
                'Made with ❤️ for YouTube Shorts creators',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.sm),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? theme.colorScheme.primary : null),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    required this.icon,
    this.iconColor,
    this.trailing,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: theme.textTheme.bodyMedium),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
