import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_dropdown.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../core/widgets/common/generated_text_result.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/models/language.dart';
import '../providers/content_provider.dart';

class ContentGeneratorScreen extends ConsumerStatefulWidget {
  const ContentGeneratorScreen({super.key});

  @override
  ConsumerState<ContentGeneratorScreen> createState() => _ContentGeneratorScreenState();
}

class _ContentGeneratorScreenState extends ConsumerState<ContentGeneratorScreen> {
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
    final state = ref.read(contentProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'content_generate_tapped',
      parameters: {'language': _language.code},
    );
    setState(() => _hasGenerated = true);
    await ref.read(contentProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          language: _language.name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentState = ref.watch(contentProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Content Generator'),
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
                      Text('Generate video script', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. 5 Productivity Tips, Jesus Miracles',
                        maxLines: 2,
                        maxLength: 200,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.validateTopic(v, min: 3, max: 200, field: 'Topic'),
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
                        label: 'Generate Content',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && contentState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                GeneratedTextResult(
                  state: contentState.whenData((data) => data.hook),
                  shareText: () => ref.read(contentProvider.notifier).lastResult?.shareText ?? '',
                  onSave: ref.read(contentProvider.notifier).saveToHistory,
                  onRetry: _generate,
                  hasGenerated: _hasGenerated,
                  emptyIcon: Icons.article_rounded,
                  emptyTitle: 'No content yet',
                  emptySubtitle: 'Enter a topic and tap Generate to create a hook, main content, and CTA.',
                  sections: contentState.maybeWhen(
                    data: (data) => [
                      GeneratedSection(label: '🎬 Hook', text: data.hook),
                      GeneratedSection(label: '📝 Main Content', text: data.mainContent),
                      GeneratedSection(label: '📣 Call to Action', text: data.cta),
                    ],
                    orElse: () => null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
