import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

/// A horizontal set of tappable prompt suggestion chips.
///
/// Tapping a chip calls [onSelected] with its text (typically to fill a field).
class PromptSuggestions extends StatelessWidget {
  const PromptSuggestions({
    super.key,
    required this.suggestions,
    required this.onSelected,
    this.label = 'Try',
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: suggestions
              .map((s) => _SuggestionChip(label: s, onTap: () => onSelected(s)))
              .toList(),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 15, color: AppColors.primaryDark),
              const SizedBox(width: 5),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
