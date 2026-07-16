import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_dropdown.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../core/widgets/common/empty_state.dart';
import '../../../core/widgets/common/error_state.dart';
import '../../../core/widgets/common/prompt_suggestions.dart';
import '../../../core/widgets/common/shimmer_loading.dart';
import '../../../shared/catalogs/duration_catalog.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/catalogs/tone_catalog.dart';
import '../../../shared/models/content_duration.dart';
import '../../../shared/models/content_format.dart';
import '../../../shared/models/language.dart';
import '../../../shared/models/tone.dart';
import '../providers/content_studio_provider.dart';
import '../widgets/content_package_editor.dart';

/// The AI Content Studio — an all-in-one content package generator that lives
/// in the Create tab.
class ContentStudioScreen extends ConsumerStatefulWidget {
  const ContentStudioScreen({super.key});

  @override
  ConsumerState<ContentStudioScreen> createState() =>
      _ContentStudioScreenState();
}

class _ContentStudioScreenState extends ConsumerState<ContentStudioScreen> {
  final _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  ContentFormat _format = ContentFormat.shorts;
  Language _language = LanguageCatalog.defaultLanguage;
  Tone _tone = ToneCatalog.defaultTone;
  late ContentDuration _duration = DurationCatalog.defaultFor(_format);
  bool _hasGenerated = false;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _onFormatChanged(ContentFormat? format) {
    if (format == null || format == _format) return;
    setState(() {
      _format = format;
      // Duration options differ per format — reset to the format's default.
      _duration = DurationCatalog.defaultFor(format);
    });
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final state = ref.read(contentStudioProvider);
    // Prevent a second request while one is pending (Req 4.1).
    if (_hasGenerated && state.isLoading) return;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'content_studio_generate_tapped',
      parameters: {
        'format': _format.name,
        'language': _language.code,
        'tone': _tone.label,
        'duration': _duration.label,
      },
    );

    setState(() => _hasGenerated = true);
    await ref.read(contentStudioProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          format: _format,
          language: _language.name,
          tone: _tone,
          duration: _duration,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studioState = ref.watch(contentStudioProvider);
    final durationOptions = DurationCatalog.forFormat(_format);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Content Studio')),
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
                      Text('Create a full content package',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Titles, hook, script, description, keywords, hashtags, thumbnail text & CTA — all at once.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _topicController,
                        label: 'Topic',
                        hint: 'e.g. 5 Productivity Tips, Jesus Miracles',
                        maxLines: 2,
                        maxLength: 200,
                        textInputAction: TextInputAction.done,
                        validator: (v) => Validators.validateTopic(v,
                            min: 3, max: 200, field: 'Topic'),
                      ),
                      const SizedBox(height: AppSizes.md),
                      PromptSuggestions(
                        suggestions: const [
                          '5 productivity tips',
                          'Morning routine',
                          'Tech explainer',
                          'Story time',
                        ],
                        onSelected: (s) =>
                            setState(() => _topicController.text = s),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<ContentFormat>(
                        value: _format,
                        items: ContentFormat.values,
                        label: 'Format',
                        itemLabel: (f) => f.description,
                        onChanged: _onFormatChanged,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<ContentDuration>(
                        value: _duration,
                        items: durationOptions,
                        label: 'Duration',
                        itemLabel: (d) => d.label,
                        onChanged: (v) {
                          if (v != null) setState(() => _duration = v);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<Tone>(
                        value: _tone,
                        items: ToneCatalog.all,
                        label: 'Tone',
                        itemLabel: (t) => t.label,
                        onChanged: (v) {
                          if (v != null) setState(() => _tone = v);
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
                        label: 'Generate Package',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _hasGenerated && studioState.isLoading,
                        onPressed: _generate,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.lg),
                _buildResult(studioState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(ContentStudioState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.auto_awesome_motion_rounded,
        title: 'No package yet',
        subtitle:
            'Enter a topic, pick your format, tone and duration, then tap Generate to create a complete content package.',
      );
    }

    return state.when(
      loading: () => const ShimmerList(itemCount: 4, itemHeight: 90),
      error: (error, _) => ErrorState(
        failure: error is Failure ? error : const UnknownFailure(),
        onRetry: _generate,
      ),
      data: (package) => ContentPackageEditor(
        key: ValueKey(package.id),
        package: package,
        onSave: (edited) =>
            ref.read(contentStudioProvider.notifier).saveToHistory(edited),
      ),
    );
  }
}
