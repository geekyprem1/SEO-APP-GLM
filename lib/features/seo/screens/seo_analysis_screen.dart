import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/result_actions_bar.dart';
import '../models/seo_analysis.dart';
import '../providers/seo_provider.dart';

class SeoAnalysisScreen extends ConsumerStatefulWidget {
  const SeoAnalysisScreen({super.key});

  @override
  ConsumerState<SeoAnalysisScreen> createState() => _SeoAnalysisScreenState();
}

class _SeoAnalysisScreenState extends ConsumerState<SeoAnalysisScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasGenerated = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(seoProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(name: 'seo_analyze_tapped');
    setState(() => _hasGenerated = true);
    await ref.read(seoProvider.notifier).analyze(
          videoUrl: Validators.normalize(_urlController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seoState = ref.watch(seoProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('SEO Analysis'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analyze your YouTube Shorts', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _urlController,
                        label: 'YouTube Shorts URL',
                        hint: 'https://youtube.com/shorts/...',
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.validateYouTubeUrl(v),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        label: 'Analyze SEO',
                        icon: Icons.analytics_rounded,
                        isLoading: _hasGenerated && seoState.isLoading,
                        onPressed: _analyze,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(seoState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AsyncValue<SeoAnalysis> state) {
    if (!_hasGenerated) {
      return _EmptyState(
        icon: Icons.analytics_rounded,
        title: 'No analysis yet',
        subtitle: 'Paste a YouTube Shorts URL and tap Analyze to get an SEO score and suggestions.',
      );
    }

    return state.when(
      loading: () => _buildLoading(),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: _analyze,
      ),
      data: (analysis) => _buildAnalysisResult(analysis),
    );
  }

  Widget _buildLoading() {
    final theme = Theme.of(context);
    return AppCard(
      child: Container(
        padding: const EdgeInsets.all(AppSizes.xl),
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Fetching video data & analyzing...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'This may take up to 15 seconds',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildAnalysisResult(SeoAnalysis analysis) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score card
        AppCard(
          child: Column(
            children: [
              if (analysis.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  child: CachedNetworkImage(
                    imageUrl: analysis.thumbnailUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              const SizedBox(height: AppSizes.md),
              _ScoreGauge(score: analysis.score, label: analysis.scoreLabel),
              const SizedBox(height: AppSizes.sm),
              if (analysis.title != null)
                Text(
                  analysis.title!,
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (analysis.channelTitle != null) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  analysis.channelTitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1, 1),
              duration: 400.ms,
            ),
        const SizedBox(height: AppSizes.md),
        // Stats row
        if (analysis.viewCount != null ||
            analysis.likeCount != null ||
            analysis.commentCount != null) ...[
          _buildStatsRow(theme, analysis),
          const SizedBox(height: AppSizes.md),
        ],
        // Suggestions
        if (analysis.suggestions.isNotEmpty) ...[
          Text('Improvement Suggestions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          ...analysis.suggestions.asMap().entries.map((entry) {
            return AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  Expanded(
                    child: Text(entry.value, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (entry.key * 80).ms, duration: 300.ms);
          }),
          const SizedBox(height: AppSizes.md),
        ],
        // Actions
        ResultActionsBar(
          text: analysis.shareText,
          onSave: ref.read(seoProvider.notifier).saveToHistory,
        ),
      ],
    );
  }

  Widget _buildStatsRow(ThemeData theme, SeoAnalysis analysis) {
    return Row(
      children: [
        if (analysis.viewCount != null)
          Expanded(child: _StatChip(
            icon: Icons.visibility_rounded,
            label: 'Views',
            value: _formatNumber(analysis.viewCount!),
          )),
        if (analysis.likeCount != null) ...[
          const SizedBox(width: AppSizes.sm),
          Expanded(child: _StatChip(
            icon: Icons.thumb_up_rounded,
            label: 'Likes',
            value: _formatNumber(analysis.likeCount!),
          )),
        ],
        if (analysis.commentCount != null) ...[
          const SizedBox(width: AppSizes.sm),
          Expanded(child: _StatChip(
            icon: Icons.comment_rounded,
            label: 'Comments',
            value: _formatNumber(analysis.commentCount!),
          )),
        ],
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// A circular score gauge showing the SEO score.
class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score, required this.label});
  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForScore(score, theme);

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: theme.textTheme.displayMedium?.copyWith(color: color),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForScore(int score, ThemeData theme) {
    if (score >= 80) return const Color(0xFF22C55E); // green
    if (score >= 60) return const Color(0xFFF59E0B); // amber
    if (score >= 40) return const Color(0xFFf97316); // orange
    return const Color(0xFFEF4444); // red
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm + 2),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleSmall),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
        ],
      ),
    );
  }
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
            Icon(icon, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.md),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
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
