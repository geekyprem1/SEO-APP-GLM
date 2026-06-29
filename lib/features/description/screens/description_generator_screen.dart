import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../core/widgets/common/generated_text_result.dart';
import '../../../core/widgets/common/prompt_suggestions.dart';
import '../providers/description_provider.dart';

class DescriptionGeneratorScreen extends ConsumerStatefulWidget {
  const DescriptionGeneratorScreen({super.key});

  @override
  ConsumerState<DescriptionGeneratorScreen> createState() => _DescriptionGeneratorScreenState();
}

class _DescriptionGeneratorScreenState extends ConsumerState<DescriptionGeneratorScreen> {
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasGenerated = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(descriptionProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(name: 'description_generate_tapped');
    setState(() => _hasGenerated = true);
    await ref.read(descriptionProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descState = ref.watch(descriptionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Description Generator'),
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
                      Text('Generate SEO description', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Jesus Facts, Tech News',
                        maxLines: 2,
                        maxLength: 200,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.validateTopic(v, min: 3, max: 200, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'Horror story',
                          'Tech review',
                          'Travel vlog',
                          'Product unboxing',
                        ],
                        onSelected: (s) => setState(() => _topicController.text = s),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        label: 'Generate Description',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && descState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                GeneratedTextResult(
                  state: descState.whenData((data) => data.description),
                  shareText: () => ref.read(descriptionProvider.notifier).lastResult?.shareText ?? '',
                  onSave: ref.read(descriptionProvider.notifier).saveToHistory,
                  onRetry: _generate,
                  hasGenerated: _hasGenerated,
                  emptyIcon: Icons.description_rounded,
                  emptyTitle: 'No description yet',
                  emptySubtitle: 'Enter a topic and tap Generate to create an SEO-optimized description.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
