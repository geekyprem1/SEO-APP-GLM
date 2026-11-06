import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../core/widgets/common/empty_state.dart';
import '../models/project.dart';
import '../repository/project_repository.dart';

/// The Saved Projects board: a creator's videos in the
/// Draft → Ready → Published workflow.
///
/// In-progress projects come first — the growth findings call this the
/// "reason to return": unfinished work is visible the moment the app opens.
class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projects = ref.watch(projectsProvider);
    final inProgress =
        projects.where((p) => p.isInProgress).toList(growable: false);
    final published =
        projects.where((p) => !p.isInProgress).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      body: SafeArea(
        child: projects.isEmpty
            ? const EmptyState(
                icon: Icons.movie_filter_rounded,
                title: 'No projects yet',
                subtitle:
                    'Generate a package in the Create tab and tap Save — it '
                    'becomes a project you can finish later.',
              )
            : ListView(
                padding: const EdgeInsets.all(AppSizes.paddingLg),
                children: [
                  if (inProgress.isNotEmpty) ...[
                    _sectionTitle(
                        theme, 'In progress', '${inProgress.length}'),
                    ...inProgress.map((p) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSizes.sm),
                          child: _ProjectCard(project: p),
                        )),
                  ],
                  if (published.isNotEmpty) ...[
                    if (inProgress.isNotEmpty)
                      const SizedBox(height: AppSizes.lg),
                    _sectionTitle(
                        theme, 'Published', '${published.length}'),
                    ...published.map((p) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSizes.sm),
                          child: _ProjectCard(project: p),
                        )),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title, String count) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.sm,
        bottom: AppSizes.md,
      ),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(width: AppSizes.sm),
          Text(
            count,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = project.status;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.projectDetailFor(project.id)),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                status == ProjectStatus.published
                    ? Icons.check_circle_rounded
                    : Icons.movie_filter_rounded,
                color: status == ProjectStatus.published
                    ? AppColors.success
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.topic.isEmpty ? 'Untitled video' : project.topic,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app_date.DateUtils.formatFull(project.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
              const SizedBox(width: AppSizes.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      ProjectStatus.draft => theme.colorScheme.onSurfaceVariant,
      ProjectStatus.ready => AppColors.warning,
      ProjectStatus.published => AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
