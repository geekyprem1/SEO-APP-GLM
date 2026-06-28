import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_dropdown.dart';
import '../../../core/widgets/common/generated_list_result.dart';
import '../../../shared/catalogs/category_catalog.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/language.dart';
import '../providers/viral_ideas_provider.dart';

class ViralIdeasScreen extends ConsumerStatefulWidget {
  const ViralIdeasScreen({super.key});

  @override
  ConsumerState<ViralIdeasScreen> createState() => _ViralIdeasScreenState();
}

class _ViralIdeasScreenState extends ConsumerState<ViralIdeasScreen> {
  Category _category = CategoryCatalog.defaultCategory;
  Language _language = LanguageCatalog.defaultLanguage;
  bool _hasGenerated = false;

  Future<void> _generate() async {
    final state = ref.read(viralIdeasProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'viral_ideas_generate_tapped',
      parameters: {'category': _category.id, 'language': _language.code},
    );
    setState(() => _hasGenerated = true);
    await ref.read(viralIdeasProvider.notifier).generate(
          category: _category.name,
          language: _language.name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ideasState = ref.watch(viralIdeasProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Viral Shorts Ideas'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generate viral content ideas', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSizes.md),
                    AppDropdown<Category>(
                      value: _category,
                      items: CategoryCatalog.all,
                      label: 'Category',
                      itemLabel: (c) => c.name,
                      onChanged: (v) {
                        if (v != null) setState(() => _category = v);
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
                      label: 'Generate Ideas',
                      icon: Icons.local_fire_department_rounded,
                      isLoading: _hasGenerated && ideasState.isLoading,
                      onPressed: _generate,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSizes.lg),
              GeneratedListResult(
                state: ideasState.whenData((data) => data.ideas),
                shareText: () => ref.read(viralIdeasProvider.notifier).lastResult?.shareText ?? '',
                onSave: ref.read(viralIdeasProvider.notifier).saveToHistory,
                onRetry: _generate,
                hasGenerated: _hasGenerated,
                emptyIcon: Icons.lightbulb_outline_rounded,
                emptyTitle: 'No ideas yet',
                emptySubtitle: 'Select a category and language, then tap Generate for 20 viral ideas.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
