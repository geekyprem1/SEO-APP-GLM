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
import '../../../core/widgets/common/generated_list_result.dart';
import '../../../core/widgets/common/prompt_suggestions.dart';
import '../providers/hashtag_provider.dart';

class HashtagGeneratorScreen extends ConsumerStatefulWidget {
  const HashtagGeneratorScreen({super.key});

  @override
  ConsumerState<HashtagGeneratorScreen> createState() => _HashtagGeneratorScreenState();
}

class _HashtagGeneratorScreenState extends ConsumerState<HashtagGeneratorScreen> {
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
    final state = ref.read(hashtagProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(name: 'hashtag_generate_tapped');
    setState(() => _hasGenerated = true);
    await ref.read(hashtagProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hashtagState = ref.watch(hashtagProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hashtag Generator'),
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
                      Text('Generate relevant hashtags', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. Gaming Highlights, Jesus Facts',
                        maxLines: 2,
                        maxLength: 120,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.validateTopic(v, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          'Gaming',
                          'Fitness',
                          'Comedy',
                          'Travel',
                        ],
                        onSelected: (s) => setState(() => _topicController.text = s),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        label: 'Generate Hashtags',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && hashtagState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                GeneratedListResult(
                  state: hashtagState.whenData((data) => data.hashtags),
                  shareText: () => ref.read(hashtagProvider.notifier).lastResult?.shareText ?? '',
                  onSave: ref.read(hashtagProvider.notifier).saveToHistory,
                  onRetry: _generate,
                  hasGenerated: _hasGenerated,
                  emptyIcon: Icons.tag_rounded,
                  emptyTitle: 'No hashtags yet',
                  emptySubtitle: 'Enter a topic and tap Generate to create 20 relevant hashtags.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
