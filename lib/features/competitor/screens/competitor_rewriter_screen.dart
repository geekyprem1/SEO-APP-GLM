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
import '../../../core/widgets/common/result_actions_bar.dart';
import '../../../core/widgets/common/shimmer_loading.dart';
import '../../../core/widgets/common/success_reveal.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/models/language.dart';
import '../models/generated_competitor_titles.dart';
import '../providers/competitor_provider.dart';

class CompetitorRewriterScreen extends ConsumerStatefulWidget {
  const CompetitorRewriterScreen({super.key});

  @override
  ConsumerState<CompetitorRewriterScreen> createState() =>
      _CompetitorRewriterScreenState();
}

class _CompetitorRewriterScreenState
    extends ConsumerState<CompetitorRewriterScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Language _language = LanguageCatalog.defaultLanguage;
  bool _hasGenerated = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(competitorProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
          name: 'competitor_generate_tapped',
          parameters: {'language': _language.code},
        );

    setState(() => _hasGenerated = true);
    await ref.read(competitorProvider.notifier).generate(
          sourceTitle: Validators.normalize(_titleController.text),
          language: _language.name,
        );
  }

  void _copy(String text) {
    ref.read(clipboardServiceProvider).copy(text);
    UiUtils.showSuccessSnackBar(context, 'Title copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(competitorProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Title Rewriter'),
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
                        'Beat competing titles with stronger SEO variants',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _titleController,
                        label: 'Competitor title',
                        hint: 'Paste a competing video title',
                        maxLines: 3,
                        maxLength: 160,
                        validator: (v) =>
                            Validators.validateTopic(v, field: 'Title'),
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
                        label: 'Rewrite Titles',
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

  Widget _buildResult(CompetitorState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.compare_arrows_rounded,
        title: 'No rewrites yet',
        subtitle: 'Paste a competitor title to generate stronger alternatives.',
      );
    }
    return state.when(
      loading: () => const ShimmerList(itemCount: 8, itemHeight: 56),
      error: (e, _) => ErrorState(
        failure: e is Failure ? e : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (data) => SuccessReveal(child: _list(data)),
    );
  }

  Widget _list(GeneratedCompetitorTitles data) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultActionsBar(
          text: data.shareText,
          onSave: ref.read(competitorProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.md),
        ...data.titles.asMap().entries.map((e) {
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
