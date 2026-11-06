import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../content_studio/models/content_package.dart';
import '../../content_studio/widgets/content_package_editor.dart';
import '../models/project.dart';
import '../repository/project_repository.dart';

/// Detail screen for one project: the fully editable content package plus
/// the Draft → Ready → Published workflow controls.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final project = ref.watch(projectByIdProvider(id));

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const Center(child: Text('Project not found')),
      );
    }

    final status = project.status;
    final next = status.next;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.topic.isEmpty ? 'Untitled video' : project.topic,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          _StatusBadge(status: status),
          const SizedBox(width: AppSizes.md),
          IconButton(
            tooltip: 'Delete project',
            icon: Icon(Icons.delete_outline_rounded,
                color: theme.colorScheme.error),
            onPressed: () => _confirmDelete(context, ref, project),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (next != null) ...[
                FilledButton.icon(
                  onPressed: () => _advance(context, ref, project, next),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    next == ProjectStatus.ready
                        ? 'Mark as ready to record'
                        : 'Mark as published',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'This video is live 🎉',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
              ],
              ContentPackageEditor(
                key: ValueKey(project.id),
                package: project.package,
                saveLabel: 'Update',
                onSave: (edited) => _savePackage(context, ref, project, edited),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _savePackage(
    BuildContext context,
    WidgetRef ref,
    Project project,
    ContentPackage editedPackage,
  ) async {
    try {
      await ref
          .read(projectRepositoryProvider)
          .updatePackage(project.id, editedPackage);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _advance(
    BuildContext context,
    WidgetRef ref,
    Project project,
    ProjectStatus next,
  ) async {
    final repository = ref.read(projectRepositoryProvider);
    await repository.setStatus(project.id, next);

    ref.read(analyticsServiceProvider).logEvent(
      name: 'project_status_changed',
      parameters: {
        'from': project.status.name,
        'to': next.name,
      },
    );

    if (context.mounted) {
      UiUtils.showSuccessSnackBar(
        context,
        next == ProjectStatus.published
            ? 'Video published — great work! 🎉'
            : 'Marked as ready',
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project?'),
        content: const Text(
          'This removes the project from My Projects. The matching entry in '
          'History stays untouched.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(projectRepositoryProvider).delete(project.id);
    ref.read(analyticsServiceProvider).logEvent(
      name: 'project_deleted',
      parameters: {'status': project.status.name},
    );
    if (context.mounted) {
      UiUtils.showSuccessSnackBar(context, 'Project deleted');
      context.pop();
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      ProjectStatus.draft => theme.colorScheme.onSurfaceVariant,
      ProjectStatus.ready => AppColors.warning,
      ProjectStatus.published => AppColors.success,
    };

    return Center(
      child: Container(
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
      ),
    );
  }
}
