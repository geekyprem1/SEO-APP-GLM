import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/routes.dart';
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
import '../../channel_profile/providers/channel_profile_provider.dart';
import '../../projects/repository/project_repository.dart';
import '../models/content_package.dart';
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
  bool _isSubmitting = false;
  // Advanced options stay collapsed on first use — the growth findings (P0)
  // say a creator should reach a useful result with just topic + language.
  bool _showAdvanced = false;
  // When the saved Channel Profile changes a default, the in-form selection
  // follows until the creator picks one themselves (then it stays manual).
  bool _languageTouched = false;
  bool _toneTouched = false;

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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Prevent a second request while one is pending (Req 4.1).
    if (_isSubmitting) return;

    final channelProfile = ref.read(channelProfileProvider);
    // The saved Channel Profile is the default until the creator overrides
    // it in this form (then the manual pick sticks for the session).
    final language = (!_languageTouched && channelProfile.language != null)
        ? channelProfile.language!
        : _language;
    final tone = (!_toneTouched && channelProfile.tone != null)
        ? channelProfile.tone!
        : _tone;

    ref.read(analyticsServiceProvider).logEvent(
      name: 'content_studio_generate_tapped',
      parameters: {
        'format': _format.name,
        'language': language.code,
        'tone': tone.label,
        'duration': _duration.label,
        // Firebase Analytics params must be String or num — no bools.
        'channelProfileApplied': channelProfile.isNotEmpty ? 'yes' : 'no',
      },
    );

    setState(() {
      _hasGenerated = true;
      _isSubmitting = true;
    });
    try {
    await ref.read(contentStudioProvider.notifier).generate(
          topic: Validators.normalize(_topicController.text),
          format: _format,
          language: language.name,
          tone: tone,
          duration: _duration,
          channelProfile: channelProfile,
        );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studioState = ref.watch(contentStudioProvider);
    final durationOptions = DurationCatalog.forFormat(_format);
    final channelProfile = ref.watch(channelProfileProvider);
    final language = (!_languageTouched && channelProfile.language != null)
        ? channelProfile.language!
        : _language;
    final tone = (!_toneTouched && channelProfile.tone != null)
        ? channelProfile.tone!
        : _tone;

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
                        'Enter a topic — get titles, hook, script, description, keywords, hashtags, thumbnail text & CTA in one go.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      if (channelProfile.isNotEmpty) ...[
                        InkWell(
                          onTap: () => context.push(AppRoutes.channelProfile),
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm + 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusLg),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.video_camera_front_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Expanded(
                                  child: Text(
                                    'Channel profile applied · ${channelProfile.summary}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => setState(
                              () => _showAdvanced = !_showAdvanced),
                          icon: Icon(
                            _showAdvanced
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.tune_rounded,
                            size: AppSizes.iconSm,
                          ),
                          label: Text(
                            _showAdvanced
                                ? 'Hide format, duration & tone'
                                : 'More options: format, duration & tone',
                          ),
                        ),
                      ),
                      if (_showAdvanced) ...[
                        const SizedBox(height: AppSizes.sm),
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
                          value: tone,
                          items: ToneCatalog.all,
                          label: 'Tone',
                          itemLabel: (t) => t.label,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _tone = v;
                                _toneTouched = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.md),
                      ],
                      AppDropdown<Language>(
                        value: language,
                        items: LanguageCatalog.all,
                        label: 'Language',
                        itemLabel: (l) => l.name,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _language = v;
                              _languageTouched = true;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        label: 'Generate Package',
                        icon: Icons.auto_awesome_rounded,
                        isLoading: _isSubmitting,
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

  /// Saves the (edited) package to History and, on success, also upserts it
  /// as a Draft project — the growth-findings "Saved Projects" workflow:
  /// every saved package becomes continue-able work in My Projects.
  Future<bool> _savePackage(ContentPackage edited) async {
    final saved = await ref
        .read(contentStudioProvider.notifier)
        .saveToHistory(edited);
    if (!saved) return false;

    try {
      await ref.read(projectRepositoryProvider).upsertFromPackage(edited);
      ref.read(analyticsServiceProvider).logEvent(
        name: 'project_saved',
        parameters: {'topic': edited.topic},
      );
    } catch (_) {
      // History save succeeded; a project-write failure must not read as a
      // failed save. The next save retries the upsert.
    }
    return true;
  }

  Widget _buildResult(ContentStudioState state) {
    if (!_hasGenerated) {
      return const EmptyState(
        icon: Icons.auto_awesome_motion_rounded,
        title: 'No package yet',
        subtitle:
            'Just enter a topic, pick your language and tap Generate. Format, duration and tone can be tuned anytime.',
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
        onSave: (edited) => _savePackage(edited),
      ),
    );
  }
}
