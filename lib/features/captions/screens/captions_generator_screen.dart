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
import '../models/generated_captions.dart';
import '../providers/captions_provider.dart';

class CaptionsGeneratorScreen extends ConsumerStatefulWidget {
  const CaptionsGeneratorScreen({super.key});

  @override
  ConsumerState<CaptionsGeneratorScreen> createState() =>
      _CaptionsGeneratorScreenState();
}

class _CaptionsGeneratorScreenState
    extends ConsumerState<CaptionsGeneratorScreen> {
  final _topicController = TextEditingController();
  final _contextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Language _language = LanguageCatalog.defaultLanguage;
  bool _hasGenerated = false;

  @override
  void dispose() {
    _topicController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(captionsProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
          name: 'captions_generate_tapped',
          parameters: {'language': _language.code},
        );

    setState(() => _hasGenerated = true);
    await ref.read(captionsProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
          context: _contextController.text.trim().isEmpty
              ? null
              : _contextController.text.trim(),
        );
  }

  void _copySingle(String text) {
    ref.read(clipboardServiceProvider).copy(text);
    UiUtils.showSuccessSnackBar(context, 'Caption copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionsState = ref.watch(captionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('On-screen Captions'),
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
                        'Big, readable text overlays for Shorts',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. 3 habits that made me rich',
                        maxLines: 2,
                        maxLength: 120,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'Study tips',
                          'Cooking hack',
                          'Phone settings',
                          'Travel mistake',
                        ],
                        onSelected: (s) =>
                            setState(() => _topicController.text = s),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _contextController,
                        label: 'Script context (optional)',
                        hint: 'Paste a rough script or key points',
                        maxLines: 3,
                        maxLength: 400,
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
                        label: 'Generate Captions',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && captionsState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(captionsState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(CaptionsState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.closed_caption_rounded,
        title: 'No captions yet',
        subtitle:
            'Enter a topic and generate punchy on-screen text for your Short.',
      );
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 8, itemHeight: 56),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (captions) => SuccessReveal(child: _buildList(captions)),
    );
  }

  Widget _buildList(GeneratedCaptions captions) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: captions.shareText,
          onSave: ref.read(captionsProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: captions.captions.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final line = captions.captions[index];
            return AppCard(
              onTap: () => _copySingle(line.text),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(line.text, style: theme.textTheme.titleSmall),
                        if (line.beats != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            line.beats!,
                            style: theme.textTheme.labelSmall?.copyWith(
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
            );
          },
        ),
      ],
    );
  }
}
