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
import '../models/generated_hook.dart';
import '../providers/hook_provider.dart';

class HookGeneratorScreen extends ConsumerStatefulWidget {
  const HookGeneratorScreen({super.key});

  @override
  ConsumerState<HookGeneratorScreen> createState() =>
      _HookGeneratorScreenState();
}

class _HookGeneratorScreenState extends ConsumerState<HookGeneratorScreen> {
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
    final state = ref.read(hookProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
          name: 'hook_generate_tapped',
          parameters: {'language': _language.code},
        );

    setState(() => _hasGenerated = true);
    await ref.read(hookProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
        );
  }

  void _copySingle(String text) {
    ref.read(clipboardServiceProvider).copy(text);
    UiUtils.showSuccessSnackBar(context, 'Hook copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hookState = ref.watch(hookProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hook Generator'),
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
                        'First 3-second openers that stop the scroll',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Morning routine that changed my life',
                        maxLines: 2,
                        maxLength: 120,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'Money mistakes',
                          'Gym transformation',
                          'AI tools',
                          'Relationship advice',
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
                        label: 'Generate Hooks',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && hookState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(hookState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(HookState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.campaign_rounded,
        title: 'No hooks yet',
        subtitle:
            'Enter a topic and tap Generate to create scroll-stopping openers.',
      );
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 8, itemHeight: 56),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (hook) => SuccessReveal(child: _buildList(hook)),
    );
  }

  Widget _buildList(GeneratedHook hook) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: hook.shareText,
          onSave: ref.read(hookProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hook.hooks.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final text = hook.hooks[index];
            return AppCard(
              onTap: () => _copySingle(text),
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
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm + 4),
                  Expanded(
                    child: Text(text, style: theme.textTheme.bodyMedium),
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
