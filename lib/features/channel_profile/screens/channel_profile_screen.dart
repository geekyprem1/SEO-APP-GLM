import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_card.dart';
import '../../../core/widgets/common/app_dropdown.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../../../shared/catalogs/language_catalog.dart';
import '../../../shared/catalogs/tone_catalog.dart';
import '../../../shared/models/language.dart';
import '../../../shared/models/tone.dart';
import '../../../core/utils/ui_utils.dart';
import '../models/channel_profile.dart';
import '../providers/channel_profile_provider.dart';

/// Edit screen for the creator's channel profile ("brand memory").
///
/// Everything saved here is reused by the AI generators — most importantly
/// the Content Studio — so creators don't re-answer the same questions on
/// every visit (growth findings, feature #1).
class ChannelProfileScreen extends ConsumerStatefulWidget {
  const ChannelProfileScreen({super.key});

  @override
  ConsumerState<ChannelProfileScreen> createState() =>
      _ChannelProfileScreenState();
}

class _ChannelProfileScreenState extends ConsumerState<ChannelProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicheController = TextEditingController();
  final _audienceController = TextEditingController();
  final _styleNotesController = TextEditingController();

  Language? _language;
  Tone? _tone;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nicheController.dispose();
    _audienceController.dispose();
    _styleNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Prefill once from the stored profile (the screen is pushed fresh each
    // time, so a one-shot init keeps edits stable while the user types).
    if (!_initialized) {
      final profile = ref.read(channelProfileProvider);
      _nicheController.text = profile.niche;
      _audienceController.text = profile.audience;
      _styleNotesController.text = profile.styleNotes;
      _language = profile.language;
      _tone = profile.tone;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Channel Profile')),
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
                      Text('Remember your channel',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'Save your niche, audience and style once — Tubora '
                        'reuses it in every AI generation, so you never have '
                        'to repeat yourself.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _nicheController,
                        label: 'Channel niche',
                        hint: 'e.g. Hindi street-food cooking, tech reviews',
                        maxLines: 1,
                        maxLength: 120,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _audienceController,
                        label: 'Audience',
                        hint: 'e.g. 18–30 foodies in tier-2 cities',
                        maxLines: 1,
                        maxLength: 120,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<Language>(
                        value: _language,
                        items: LanguageCatalog.all,
                        label: 'Default language',
                        hint: 'Not set — use app default',
                        itemLabel: (l) => l.name,
                        onChanged: (v) => setState(() => _language = v),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppDropdown<Tone>(
                        value: _tone,
                        items: ToneCatalog.all,
                        label: 'Default tone',
                        hint: 'Not set — use app default',
                        itemLabel: (t) => t.label,
                        onChanged: (v) => setState(() => _tone = v),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _styleNotesController,
                        label: 'Style notes (optional)',
                        hint:
                            'e.g. I speak in casual Hinglish, use desi examples, avoid English jargon',
                        maxLines: 3,
                        maxLength: 300,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppButton(
                  label: 'Save profile',
                  icon: Icons.check_rounded,
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
                const SizedBox(height: AppSizes.sm),
                if (ref.watch(channelProfileProvider).isNotEmpty)
                  TextButton.icon(
                    onPressed: _isSaving ? null : _clear,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear profile'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final profile = ChannelProfile(
        niche: _nicheController.text.trim(),
        audience: _audienceController.text.trim(),
        language: _language,
        tone: _tone,
        styleNotes: _styleNotesController.text.trim(),
      );
      await ref.read(channelProfileProvider.notifier).save(profile);

      ref.read(analyticsServiceProvider).logEvent(
        name: 'channel_profile_saved',
        parameters: {
          // Firebase Analytics params must be String or num — no bools.
          'hasNiche': profile.niche.isNotEmpty ? 'yes' : 'no',
          'hasAudience': profile.audience.isNotEmpty ? 'yes' : 'no',
          'language': profile.language?.code ?? 'unset',
          'tone': profile.tone?.label ?? 'unset',
          'hasStyleNotes': profile.styleNotes.isNotEmpty ? 'yes' : 'no',
        },
      );

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, 'Channel profile saved');
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _clear() async {
    await ref.read(channelProfileProvider.notifier).clear();
    if (mounted) {
      setState(() {
        _nicheController.clear();
        _audienceController.clear();
        _styleNotesController.clear();
        _language = null;
        _tone = null;
      });
      UiUtils.showSuccessSnackBar(context, 'Channel profile cleared');
    }
  }
}
