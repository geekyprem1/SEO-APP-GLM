import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/generated_text_result.dart';
import '../../../core/widgets/common/result_actions_bar.dart';
import '../../content/models/generated_content.dart';
import '../../description/models/generated_description.dart';
import '../../hashtags/models/generated_hashtag.dart';
import '../../seo/models/seo_analysis.dart';
import '../../title/models/generated_title.dart';
import '../../trending/models/trending_topics.dart';
import '../../viral_ideas/models/viral_ideas.dart';
import '../models/history_item.dart';
import '../providers/history_provider.dart';
import '../widgets/history_type_meta.dart';

/// Detail screen for a single history item.
/// Rehydrates the concrete model from [HistoryType] + [data] and displays it.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final itemAsync = ref.watch(historyItemByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('History Detail'),
      ),
      body: SafeArea(
        child: itemAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            failure: error is Failure ? error : const UnknownFailure(),
            onRetry: () => ref.invalidate(historyItemByIdProvider(id)),
          ),
          data: (item) {
            if (item == null) {
              return _buildNotFound(context);
            }
            return _buildContent(context, theme, item, ref);
          },
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 64),
          const SizedBox(height: AppSizes.md),
          Text('Item not found',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.lg),
          FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    HistoryItem item,
    WidgetRef ref,
  ) {
    final meta = HistoryTypeMeta.forType(item.type);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: AppSizes.iconLg),
                ),
                const SizedBox(width: AppSizes.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.displayTitle,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(
                        '${meta.label} • ${app_date.DateUtils.formatFull(item.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: AppSizes.lg),
          // Rehydrated content
          _buildRehydratedContent(context, theme, item),
        ],
      ),
    );
  }

  /// Rehydrates the concrete model from [item.type] + [item.data] and
  /// renders the appropriate content.
  Widget _buildRehydratedContent(
    BuildContext context,
    ThemeData theme,
    HistoryItem item,
  ) {
    switch (item.type) {
      case HistoryType.title:
        final title = GeneratedTitle.fromJson(item.data);
        return _buildListContent(context, theme, title.titles, title.shareText);

      case HistoryType.hashtag:
        final hashtag = GeneratedHashtag.fromJson(item.data);
        return _buildListContent(context, theme, hashtag.hashtags, hashtag.shareText);

      case HistoryType.description:
        final desc = GeneratedDescription.fromJson(item.data);
        return _buildTextContent(context, theme, desc.description, desc.shareText);

      case HistoryType.content:
        final content = GeneratedContent.fromJson(item.data);
        return _buildSectionsContent(context, theme, [
          GeneratedSection(label: '🎬 Hook', text: content.hook),
          GeneratedSection(label: '📝 Main Content', text: content.mainContent),
          GeneratedSection(label: '📣 Call to Action', text: content.cta),
        ], content.shareText);

      case HistoryType.viralIdeas:
        final ideas = ViralIdeas.fromJson(item.data);
        return _buildListContent(context, theme, ideas.ideas, ideas.shareText);

      case HistoryType.trending:
        final topics = TrendingTopics.fromJson(item.data);
        return _buildListContent(context, theme, topics.topics, topics.shareText);

      case HistoryType.thumbnail:
        return _buildThumbnailContent(context, theme, item.data);

      case HistoryType.seo:
        final analysis = SeoAnalysis.fromJson(item.data);
        return _buildSeoContent(context, theme, analysis);
    }
  }

  Widget _buildListContent(
    BuildContext context,
    ThemeData theme,
    List<String> items,
    String shareText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(text: shareText),
        const SizedBox(height: AppSizes.md),
        ...items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
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
            ),
          ).animate().fadeIn(delay: (entry.key * 50).ms, duration: 250.ms);
        }),
      ],
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    ThemeData theme,
    String text,
    String shareText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(text: shareText),
        const SizedBox(height: AppSizes.md),
        AppCard(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildSectionsContent(
    BuildContext context,
    ThemeData theme,
    List<GeneratedSection> sections,
    String shareText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(text: shareText),
        const SizedBox(height: AppSizes.md),
        ...sections.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        )),
                    const SizedBox(height: AppSizes.sm),
                    Text(s.text, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildThumbnailContent(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    final imageUrl = data['imageUrl'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (_, __) => Container(
              height: 300,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 300,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: const Center(child: Icon(Icons.broken_image_rounded, size: 48)),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ResultActionsBar(text: imageUrl),
      ],
    );
  }

  Widget _buildSeoContent(
    BuildContext context,
    ThemeData theme,
    SeoAnalysis analysis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score card
        AppCard(
          child: Column(
            children: [
              _ScoreDisplay(score: analysis.score, label: analysis.scoreLabel),
              const SizedBox(height: AppSizes.sm),
              if (analysis.title != null)
                Text(analysis.title!,
                    style: theme.textTheme.titleSmall,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        if (analysis.suggestions.isNotEmpty) ...[
          Text('Suggestions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          ...analysis.suggestions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: AppCard(
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
              ),
            );
          }),
        ],
        const SizedBox(height: AppSizes.md),
        ResultActionsBar(text: analysis.shareText),
      ],
    );
  }
}

/// Simple score display (not animated gauge, for history view).
class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.score, required this.label});
  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForScore(score);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$score',
            style: theme.textTheme.displayMedium?.copyWith(color: color)),
        const SizedBox(width: 8),
        Text('/100\n$label',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.left),
      ],
    );
  }

  Color _colorForScore(int score) {
    if (score >= 80) return const Color(0xFF22C55E);
    if (score >= 60) return const Color(0xFFF59E0B);
    if (score >= 40) return const Color(0xFFf97316);
    return const Color(0xFFEF4444);
  }
}
