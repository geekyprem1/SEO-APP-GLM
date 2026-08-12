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
import '../models/generated_cta.dart';
import '../providers/cta_provider.dart';

class CtaGeneratorScreen extends ConsumerStatefulWidget {
  const CtaGeneratorScreen({super.key});

  @override
  ConsumerState<CtaGeneratorScreen> createState() => _CtaGeneratorScreenState();
}

class _CtaGeneratorScreenState extends ConsumerState<CtaGeneratorScreen> {
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Language _language = LanguageCatalog.defaultLanguage;
  bool _hasGenerated = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(ctaProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
          name: 'cta_generate_tapped',
          parameters: {'language': _language.code},
        );

    setState(() => _hasGenerated = true);
    await ref.read(ctaProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
        );
  }

  void _copy(String text) {
    ref.read(clipboardServiceProvider).copy(text);
    UiUtils.showSuccessSnackBar(context, 'CTA copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(ctaProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('CTA Lines'),
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
                        'End CTAs that convert viewers',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Budget meal prep for beginners',
                        maxLines: 2,
                        maxLength: 120,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'Fitness challenge',
                          'Side hustle tip',
                          'App tutorial',
                          'Storytime ending',
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
                        label: 'Generate CTAs',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && state.isLoading,
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

  Widget _buildResult(CtaState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.ads_click_rounded,
        title: 'No CTAs yet',
        subtitle: 'Enter a topic to generate subscribe, comment, and follow lines.',
      );
    }
    return state.when(
      loading: () => const ShimmerList(itemCount: 8, itemHeight: 56),
      error: (e, _) => ErrorState(
        failure: e is Failure ? e : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (cta) => SuccessReveal(child: _list(cta)),
    );
  }

  Widget _list(GeneratedCta cta) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: cta.shareText,
          onSave: ref.read(ctaProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.md),
        ...cta.ctas.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: AppCard(
              onTap: () => _copy(e.value),
              child: Row(
                children: [
                  Expanded(
                    child: Text(e.value, style: theme.textTheme.bodyMedium),
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
