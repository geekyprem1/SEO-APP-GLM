import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/utils/ui_utils.dart';

/// A row of action buttons (Copy, Share, Save) for a generated result.
class ResultActionsBar extends ConsumerWidget {
  const ResultActionsBar({
    super.key,
    required this.text,
    this.onSave,
    this.saveLabel = 'Save',
  });

  /// The text to copy / share.
  final String text;

  /// Called when Save is tapped.
  final Future<bool> Function()? onSave;

  final String saveLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () async {
            await ref.read(clipboardServiceProvider).copy(text);
            ref.read(hapticServiceProvider).light();
            if (context.mounted) {
              UiUtils.showSuccessSnackBar(context, 'Copied to clipboard');
            }
          },
        ),
        const SizedBox(width: AppSizes.sm),
        _ActionButton(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () async {
            await ref.read(shareServiceProvider).share(text);
            ref.read(hapticServiceProvider).light();
          },
        ),
        if (onSave != null) ...[
          const SizedBox(width: AppSizes.sm),
          _ActionButton(
            icon: Icons.bookmark_add_outlined,
            label: saveLabel,
            onTap: () async {
              final success = await onSave!();
              ref.read(hapticServiceProvider).light();
              if (context.mounted) {
                UiUtils.showSnackBar(
                  context,
                  success ? 'Saved to history' : 'Failed to save',
                  success: success,
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: theme.textTheme.labelMedium),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm,
            vertical: AppSizes.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
      ),
    );
  }
}
