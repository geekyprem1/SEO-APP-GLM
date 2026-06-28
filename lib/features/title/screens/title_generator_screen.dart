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
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/models/language.dart';
import '../models/generated_title.dart';
import '../providers/title_provider.dart';

/// Title Generator screen — the reference feature.
///
/// Flow: Input (topic + language) → Generate → 10 titles → Copy/Share/Save.
class TitleGeneratorScreen extends ConsumerStatefulWidget {
  const TitleGeneratorScreen({super.key});

  @override
  ConsumerState<TitleGeneratorScreen> createState() => _TitleGeneratorScreenState();
}

class _TitleGeneratorScreenState extends ConsumerState<TitleGeneratorScreen> {
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

    // Prevent duplicate requests.
    final state = ref.read(titleProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'title_generate_tapped',
      parameters: {'language': _language.code},
    );

    setState(() => _hasGenerated = true);
    await ref.read(titleProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
        );
  }

  void _copySingle(String title) {
    ref.read(clipboardServiceProvider).copy(title);
    UiUtils.showSuccessSnackBar(context, 'Title copied');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleState = ref.watch(titleProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Title Generator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input section
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Generate SEO-friendly titles',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Jesus Facts, Gaming Highlights',
                        maxLines: 2,
                        maxLength: 120,
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validators.validateTopic(v, field: 'Topic'),
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
                        label: 'Generate Titles',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && titleState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                // Result section
                _buildResult(titleState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AsyncValue<GeneratedTitle> state) {
    if (!_hasGenerated) {
      return EmptyState(
        icon: Icons.title_rounded,
        title: 'No titles yet',
        subtitle: 'Enter a topic and tap Generate to create 10 SEO-friendly titles.',
      ).animate().fadeIn();
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 10, itemHeight: 56),
      error: (error, _) => ErrorState(
        failure: error is Failure
            ? error
            : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (title) => _buildTitleList(title),
    );
  }

  Widget _buildTitleList(GeneratedTitle title) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bulk actions
        ResultActionsBar(
          text: title.shareText,
          onSave: ref.read(titleProvider.notifier).saveToHistory,
        ),
        const SizedBox(height: AppSizes.md),
        // Individual titles
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: title.titles.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final t = title.titles[index];
            return AppCard(
              onTap: () => _copySingle(t),
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
                    child: Text(t, style: theme.textTheme.bodyMedium),
                  ),
                  Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            );
          },
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }
}
