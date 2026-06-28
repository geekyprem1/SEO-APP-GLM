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
import '../../../shared/catalogs/country_catalog.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/country.dart';
import '../../../shared/models/language.dart';
import '../providers/trending_provider.dart';

class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({super.key});

  @override
  ConsumerState<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen> {
  Category _category = CategoryCatalog.defaultCategory;
  Country _country = CountryCatalog.defaultCountry;
  Language _language = LanguageCatalog.defaultLanguage;
  bool _hasGenerated = false;

  Future<void> _generate() async {
    final state = ref.read(trendingProvider);
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'trending_generate_tapped',
      parameters: {
        'category': _category.id,
        'country': _country.code,
        'language': _language.code,
      },
    );
    setState(() => _hasGenerated = true);
    await ref.read(trendingProvider.notifier).generate(
          category: _category.name,
          country: _country.name,
          language: _language.name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendingState = ref.watch(trendingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Trending Topics'),
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
                    Text('Generate trending topics', style: theme.textTheme.titleMedium),
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
                    AppDropdown<Country>(
                      value: _country,
                      items: CountryCatalog.all,
                      label: 'Country',
                      itemLabel: (c) => c.name,
                      onChanged: (v) {
                        if (v != null) setState(() => _country = v);
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
                      label: 'Generate Topics',
                      icon: Icons.trending_up_rounded,
                      isLoading: _hasGenerated && trendingState.isLoading,
                      onPressed: _generate,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: AppSizes.lg),
              GeneratedListResult(
                state: trendingState.whenData((data) => data.topics),
                shareText: () => ref.read(trendingProvider.notifier).lastResult?.shareText ?? '',
                onSave: ref.read(trendingProvider.notifier).saveToHistory,
                onRetry: _generate,
                hasGenerated: _hasGenerated,
                emptyIcon: Icons.trending_up_rounded,
                emptyTitle: 'No topics yet',
                emptySubtitle: 'Select category, country, and language, then tap Generate.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
