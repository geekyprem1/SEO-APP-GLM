import 'package:flutter_test/flutter_test.dart';

import 'package:short_seo_ai/features/channel_profile/models/channel_profile.dart';
import 'package:short_seo_ai/features/content_studio/repository/content_studio_prompt_builder.dart';
import 'package:short_seo_ai/shared/catalogs/language_catalog.dart';
import 'package:short_seo_ai/shared/catalogs/tone_catalog.dart';
import 'package:short_seo_ai/shared/models/content_duration.dart';
import 'package:short_seo_ai/shared/models/content_format.dart';

void main() {
  group('ChannelProfile', () {
    test('empty by default and flagged as such', () {
      const profile = ChannelProfile();
      expect(profile.isEmpty, isTrue);
      expect(profile.isNotEmpty, isFalse);
      expect(profile.summary, '');
    });

    test('summary joins niche, language and tone', () {
      final profile = ChannelProfile(
        niche: 'Street food',
        language: LanguageCatalog.byCode('hi'),
        tone: ToneCatalog.byLabel('Casual'),
      );
      expect(profile.summary, 'Street food · Hindi · Casual');
    });

    test('storage round-trip preserves every field', () {
      final profile = ChannelProfile(
        niche: 'Tech reviews',
        audience: 'Gadget lovers',
        language: LanguageCatalog.byCode('hi'),
        tone: ToneCatalog.byLabel('Funny'),
        styleNotes: 'casual Hinglish',
      );

      final restored =
          channelProfileFromStorageMap(profile.toStorageMap());

      expect(restored.niche, 'Tech reviews');
      expect(restored.audience, 'Gadget lovers');
      expect(restored.language?.code, 'hi');
      expect(restored.tone?.label, 'Funny');
      expect(restored.styleNotes, 'casual Hinglish');
      expect(restored.isNotEmpty, isTrue);
    });

    test('storage round-trip of an empty profile stays empty', () {
      const profile = ChannelProfile();
      final restored =
          channelProfileFromStorageMap(profile.toStorageMap());
      expect(restored.isEmpty, isTrue);
    });
  });

  group('ContentStudioPromptBuilder channel context', () {
    test('injects niche, audience and style notes when profile is set', () {
      final request = ContentStudioPromptBuilder.build(
        topic: '5 productivity tips',
        format: ContentFormat.shorts,
        language: 'Hindi',
        tone: ToneCatalog.defaultTone,
        duration: const ContentDuration(label: 'Test', promptHint: '30 seconds'),
        channelProfile: ChannelProfile(
          niche: 'Hindi cooking',
          audience: 'foodies',
          styleNotes: 'casual Hinglish, desi examples',
        ),
      );

      expect(request.prompt, contains('Channel context'));
      expect(request.prompt, contains('Channel niche: Hindi cooking'));
      expect(request.prompt, contains('Target audience: foodies'));
      expect(request.prompt,
          contains('Creator style notes: casual Hinglish, desi examples'));
    });

    test('omits only the fields that are empty', () {
      final request = ContentStudioPromptBuilder.build(
        topic: 'Morning routine',
        format: ContentFormat.shorts,
        language: 'English',
        tone: ToneCatalog.defaultTone,
        duration: const ContentDuration(label: 'Test', promptHint: '30 seconds'),
        channelProfile: ChannelProfile(niche: 'Fitness'),
      );

      expect(request.prompt, contains('Channel niche: Fitness'));
      expect(request.prompt, isNot(contains('Target audience')));
      expect(request.prompt, isNot(contains('Creator style notes')));
    });

    test('no channel context without a profile', () {
      final request = ContentStudioPromptBuilder.build(
        topic: 'Story time',
        format: ContentFormat.shorts,
        language: 'English',
        tone: ToneCatalog.defaultTone,
        duration: const ContentDuration(label: 'Test', promptHint: '30 seconds'),
      );

      expect(request.prompt, isNot(contains('Channel context')));
    });
  });
}
