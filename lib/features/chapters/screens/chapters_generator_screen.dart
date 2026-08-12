import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_dropdown.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../core/widgets/common/empty_state.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/prompt_suggestions.dart';
import '../../../core/widgets/common/result_actions_bar.dart';
import '../../../core/widgets/common/shimmer_loading.dart';
import '../../../core/widgets/common/success_reveal.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/models/language.dart';
import '../models/generated_chapters.dart';
import '../providers/chapters_provider.dart';

class ChaptersGeneratorScreen extends ConsumerStatefulWidget {
  const ChaptersGeneratorScreen({super.key});

  @override
  ConsumerState<ChaptersGeneratorScreen> createState() =>
      _ChaptersGeneratorScreenState();
}

class _ChaptersGeneratorScreenState
    extends ConsumerState<ChaptersGeneratorScreen> {
  static const _durations = [
    '8 minutes',
    '12 minutes',
    '15 minutes',
    '20 minutes',
    '30 minutes',
  ];

  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Language _language = LanguageCatalog.defaultLanguage;
  String _duration = _durations[1];
  bool _hasGenerated = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(chaptersProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
          name: 'chapters_generate_tapped',
          parameters: {
            'language': _language.code,
            'duration': _duration,
          },
        );

    setState(() => _hasGenerated = true);
    await ref.read(chaptersProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
          durationLabel: _duration,
        );
  }

  void _copySingle(String text) {
    ref.read(clipboardServiceProvider).copy(text);
    UiUtils.showSuccessSnackBar(context, 'Chapter copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chaptersState = ref.watch(chaptersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chapter Timestamps'),
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
                      Text(
                        'YouTube chapters ready for your description',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic / outline',
                        hint: 'e.g. How I built a faceless channel in 30 days',
                        maxLines: 3,
                        maxLength: 200,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'Product review',
                          'How-to tutorial',
                          'Day in my life',
                          'Case study breakdown',
                        ],
                        onSelected: (s) =>
                            setState(() => _topicController.text = s),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<String>(
                        value: _duration,
                        items: _durations,
                        label: 'Video length',
                        itemLabel: (d) => d,
                        onChanged: (v) {
                          if (v != null) setState(() => _duration = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<Language>(
                        value: _language,
                        items: LanguageCatalog.all,
                        label: 'Language',
                        itemLabel: (l) => l.name,
                        onChanged: (v) {
                          if (v != null) setState(() => _language = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        label: 'Generate Chapters',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && chaptersState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(chaptersState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(ChaptersState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.view_timeline_rounded,
        title: 'No chapters yet',
        subtitle:
            'Enter a topic and length to generate YouTube timestamp chapters.',
      );
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 8, itemHeight: 56),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (chapters) => SuccessReveal(child: _buildList(chapters)),
    );
  }

  Widget _buildList(GeneratedChapters chapters) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: chapters.shareText,
          onSave: ref.read(chaptersProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Copy uses the YouTube description block',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chapters.chapters.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final chapter = chapters.chapters[index];
            return AppCard(
              onTap: () => _copySingle(chapter.line),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Text(
                      chapter.time,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      chapter.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
