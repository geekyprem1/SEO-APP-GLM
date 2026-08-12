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
import '../models/generated_series.dart';
import '../providers/series_provider.dart';

class SeriesGeneratorScreen extends ConsumerStatefulWidget {
  const SeriesGeneratorScreen({super.key});

  @override
  ConsumerState<SeriesGeneratorScreen> createState() =>
      _SeriesGeneratorScreenState();
}

class _SeriesGeneratorScreenState extends ConsumerState<SeriesGeneratorScreen> {
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Language _language = LanguageCatalog.defaultLanguage;
  bool _hasGenerated = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    ref.read(analyticsServiceProvider).logEvent(
          name: 'series_generate_tapped',
          parameters: {'language': _language.code},
        );

    setState(() {
      _hasGenerated = true;
      _isSubmitting = true;
    });
    try {
    await ref.read(seriesProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _copy(String text) {
    ref.read(clipboardServiceProvider).copy(text);
    UiUtils.showSuccessSnackBar(context, 'Idea copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(seriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Series Pack'),
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
                        'Turn 1 topic into a connected content series',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Starting a faceless YouTube channel',
                        maxLines: 2,
                        maxLength: 120,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'AI for creators',
                          'Budget cooking',
                          'Phone photography',
                          'Personal finance',
                        ],
                        onSelected: (s) =>
                            setState(() => _topicController.text = s),
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
                        label: 'Generate Series',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(SeriesState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.dynamic_feed_rounded,
        title: 'No series yet',
        subtitle: 'Enter one topic to generate a pack of connected episode ideas.',
      );
    }
    return state.when(
      loading: () => const ShimmerList(itemCount: 6, itemHeight: 72),
      error: (e, _) => ErrorState(
        failure: e is Failure ? e : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (data) => SuccessReveal(child: _list(data)),
    );
  }

  Widget _list(GeneratedSeries data) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: data.shareText,
          onSave: ref.read(seriesProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.md),
        ...data.ideas.asMap().entries.map((e) {
          final idea = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: AppCard(
              onTap: () => _copy(idea.line),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      '${e.key + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idea.title,
                          style: theme.textTheme.titleSmall,
                        ),
                        if (idea.angle != null &&
                            idea.angle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            idea.angle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
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
            ),
          );
        }),
      ],
    );
  }
}
