import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/services/clipboard_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/common/app_card.dart';
import '../models/content_package.dart';

/// A fully editable view of a [ContentPackage].
///
/// Renders every Generated_Field as an inline editable text field with a
/// per-field copy action, plus package-level Copy / Share / Save actions.
/// Used both after generation (in the Content Studio screen) and when opening
/// a stored package from History.
class ContentPackageEditor extends ConsumerStatefulWidget {
  const ContentPackageEditor({
    super.key,
    required this.package,
    this.onSave,
    this.saveLabel = 'Save',
  });

  final ContentPackage package;

  /// Persists the current (edited) package. Returns true on success.
  final Future<bool> Function(ContentPackage package)? onSave;

  final String saveLabel;

  @override
  ConsumerState<ContentPackageEditor> createState() =>
      _ContentPackageEditorState();
}

class _ContentPackageEditorState extends ConsumerState<ContentPackageEditor> {
  late final TextEditingController _titles;
  late final TextEditingController _hook;
  late final TextEditingController _script;
  late final TextEditingController _description;
  late final TextEditingController _keywords;
  late final TextEditingController _hashtags;
  late final TextEditingController _thumbnailTextIdeas;
  late final TextEditingController _cta;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.package;
    _titles = TextEditingController(text: p.titles.join('\n'));
    _hook = TextEditingController(text: p.hook);
    _script = TextEditingController(text: p.script);
    _description = TextEditingController(text: p.description);
    _keywords = TextEditingController(text: p.keywords.join('\n'));
    _hashtags = TextEditingController(text: p.hashtags.join('\n'));
    _thumbnailTextIdeas =
        TextEditingController(text: p.thumbnailTextIdeas.join('\n'));
    _cta = TextEditingController(text: p.cta);
  }

  @override
  void dispose() {
    _titles.dispose();
    _hook.dispose();
    _script.dispose();
    _description.dispose();
    _keywords.dispose();
    _hashtags.dispose();
    _thumbnailTextIdeas.dispose();
    _cta.dispose();
    super.dispose();
  }

  List<String> _parseList(String text) => text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  ContentPackage _currentPackage() => widget.package.copyWith(
        titles: _parseList(_titles.text),
        hook: _hook.text.trim(),
        script: _script.text.trim(),
        description: _description.text.trim(),
        keywords: _parseList(_keywords.text),
        hashtags: _parseList(_hashtags.text),
        thumbnailTextIdeas: _parseList(_thumbnailTextIdeas.text),
        cta: _cta.text.trim(),
      );

  Future<void> _copy(String text) async {
    await ref.read(clipboardServiceProvider).copy(text);
    ref.read(hapticServiceProvider).light();
    if (mounted) {
      UiUtils.showSuccessSnackBar(context, 'Copied to clipboard');
    }
  }

  Future<void> _copyAll() => _copy(_currentPackage().shareText);

  Future<void> _shareAll() async {
    await ref.read(shareServiceProvider).share(_currentPackage().shareText);
    ref.read(hapticServiceProvider).light();
  }

  Future<void> _save() async {
    final onSave = widget.onSave;
    if (onSave == null || _saving) return;
    setState(() => _saving = true);
    final success = await onSave(_currentPackage());
    ref.read(hapticServiceProvider).light();
    if (mounted) {
      setState(() => _saving = false);
      UiUtils.showSnackBar(
        context,
        success ? 'Saved to history' : 'Failed to save',
        success: success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.package;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Package-level actions.
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyAll,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy all'),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareAll,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share'),
              ),
            ),
            if (widget.onSave != null) ...[
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: Text(widget.saveLabel),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          '${p.format.label} • ${p.duration} • ${p.tone} • ${p.language}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.md),

        _EditableField(
          label: '🎯 Titles',
          helper: 'One title per line',
          controller: _titles,
          minLines: 3,
          onCopy: () => _copy(_titles.text),
        ),
        _EditableField(
          label: '⚡ Hook (first 3 seconds)',
          controller: _hook,
          minLines: 2,
          onCopy: () => _copy(_hook.text),
        ),
        _EditableField(
          label: '🎬 Script',
          controller: _script,
          minLines: 5,
          onCopy: () => _copy(_script.text),
        ),
        _EditableField(
          label: '📝 Description',
          controller: _description,
          minLines: 3,
          onCopy: () => _copy(_description.text),
        ),
        _EditableField(
          label: '🔑 Keywords',
          helper: 'One keyword per line',
          controller: _keywords,
          minLines: 3,
          onCopy: () => _copy(_keywords.text),
        ),
        _EditableField(
          label: '#️⃣ Hashtags',
          helper: 'One hashtag per line',
          controller: _hashtags,
          minLines: 3,
          onCopy: () => _copy(_hashtags.text),
        ),
        _EditableField(
          label: '🖼️ Thumbnail Text Ideas',
          helper: 'One idea per line',
          controller: _thumbnailTextIdeas,
          minLines: 3,
          onCopy: () => _copy(_thumbnailTextIdeas.text),
        ),
        _EditableField(
          label: '📣 Call to Action',
          controller: _cta,
          minLines: 2,
          onCopy: () => _copy(_cta.text),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// A single labelled, editable multi-line field inside an [AppCard], with a
/// per-field copy button.
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.onCopy,
    this.helper,
    this.minLines = 1,
  });

  final String label;
  final String? helper;
  final TextEditingController controller;
  final VoidCallback onCopy;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: onCopy,
                ),
              ],
            ),
            if (helper != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.xs),
                child: Text(
                  helper!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            TextField(
              controller: controller,
              minLines: minLines,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: AppSizes.xs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
