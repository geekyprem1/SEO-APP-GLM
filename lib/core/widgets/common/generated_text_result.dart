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

/// A reusable widget that displays a block of generated text with
/// Copy/Share/Save actions. Used by Description and Content generators.
class GeneratedTextResult extends ConsumerWidget {
  const GeneratedTextResult({
    super.key,
    required this.state,
    required this.shareText,
    required this.onSave,
    required this.onRetry,
    required this.hasGenerated,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.sections,
  });

  final AsyncValue<String> state;
  final String Function() shareText;
  final Future<bool> Function()? onSave;
  final VoidCallback onRetry;
  final bool hasGenerated;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  /// Optional labeled sections (for Content Generator: hook, main, CTA).
  /// If provided, renders each section with a label.
  final List<GeneratedSection>? sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasGenerated) {
      return _EmptyState(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle);
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 3, itemHeight: 80),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: onRetry,
      ),
      data: (_) => SuccessReveal(child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: shareText(),
          onSave: onSave,
        ),
        const SizedBox(height: AppSizes.md),
        if (sections != null)
          ...sections!.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.label, style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      )),
                      const SizedBox(height: AppSizes.sm),
                      Text(s.text, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ))
        else
          AppCard(
            child: Text(state.valueOrNull ?? '', style: theme.textTheme.bodyMedium),
          ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// A labeled section of generated text (used by Content Generator).
class GeneratedSection {
  const GeneratedSection({required this.label, required this.text});
  final String label;
  final String text;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
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
