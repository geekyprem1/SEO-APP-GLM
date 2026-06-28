import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/image_download_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_dropdown.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/result_actions_bar.dart';
import '../../../shared/catalogs/category_catalog.dart';
import '../../../shared/models/category.dart';
import '../models/generated_thumbnail.dart';
import '../providers/thumbnail_provider.dart';

class ThumbnailGeneratorScreen extends ConsumerStatefulWidget {
  const ThumbnailGeneratorScreen({super.key});

  @override
  ConsumerState<ThumbnailGeneratorScreen> createState() =>
      _ThumbnailGeneratorScreenState();
}

class _ThumbnailGeneratorScreenState
    extends ConsumerState<ThumbnailGeneratorScreen> {
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Category _category = CategoryCatalog.defaultCategory;
  ThumbnailStyle _style = ThumbnailStyle.vibrant;
  bool _hasGenerated = false;
  bool _isDownloading = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(thumbnailProvider);
    if (state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'thumbnail_generate_tapped',
      parameters: {'category': _category.id, 'style': _style.name},
    );
    setState(() => _hasGenerated = true);
    await ref.read(thumbnailProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          category: _category.name,
          style: _style,
        );
  }

  Future<void> _download() async {
    final result = ref.read(thumbnailProvider.notifier).lastResult;
    if (result == null) return;

    setState(() => _isDownloading = true);
    final success =
        await ref.read(imageDownloadServiceProvider).downloadAndSave(result.imageUrl);
    if (mounted) {
      setState(() => _isDownloading = false);
      UiUtils.showSnackBar(
        context,
        success ? 'Saved to gallery' : 'Failed to save image',
        success: success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbState = ref.watch(thumbnailProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Thumbnail Generator'),
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
                      Text('Generate AI thumbnail', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Jesus Facts, Gaming Highlights',
                        maxLines: 2,
                        maxLength: 120,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<Category>(
                        value: _category,
                        items: CategoryCatalog.all,
                        label: 'Category',
                        itemLabel: (c) => c.name,
                        onChanged: (v) {
                          if (v != null) setState(() => _category = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<ThumbnailStyle>(
                        value: _style,
                        items: ThumbnailStyle.values,
                        label: 'Style',
                        itemLabel: (s) => s.label,
                        onChanged: (v) {
                          if (v != null) setState(() => _style = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        label: 'Generate Thumbnail',
                        icon: Icons.image_rounded,
                        isLoading: thumbState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(thumbState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AsyncValue<GeneratedThumbnail> state) {
    if (!_hasGenerated) {
      return _EmptyState(
        icon: Icons.image_rounded,
        title: 'No thumbnail yet',
        subtitle:
            'Enter a topic, category, and style, then tap Generate to create an AI thumbnail.',
      );
    }

    return state.when(
      loading: () => _buildLoading(),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (thumbnail) => _buildImageResult(thumbnail),
    );
  }

  Widget _buildLoading() {
    final theme = Theme.of(context);
    return AppCard(
      child: Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'Generating thumbnail...',
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

  Widget _buildImageResult(GeneratedThumbnail thumbnail) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: CachedNetworkImage(
            imageUrl: thumbnail.imageUrl,
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
        ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1, 1),
              duration: 400.ms,
            ),
        const SizedBox(height: AppSizes.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: _isDownloading ? 'Saving...' : 'Download',
                icon: Icons.download_rounded,
                isLoading: _isDownloading,
                onPressed: _isDownloading ? null : _download,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: AppButton(
                label: 'Regenerate',
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: _generate,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        ResultActionsBar(
          text: thumbnail.imageUrl,
          onSave: ref.read(thumbnailProvider.notifier).saveToHistory,
          saveLabel: 'Save',
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
            Icon(icon,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: AppSizes.md),
            Text(title,
                style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
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
