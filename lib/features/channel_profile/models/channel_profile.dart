import '../../../../shared/catalogs/language_catalog.dart';
import '../../../../shared/catalogs/tone_catalog.dart';
import '../../../../shared/models/language.dart';
import '../../../../shared/models/tone.dart';

/// The creator's saved channel preferences — Tubora's "brand memory".
///
/// Growth findings (TUBORA_GROWTH_FINDINGS_2026-10-23.md) rank the channel
/// profile as the first feature to add: the niche, audience, language and
/// tone are remembered and reused in every AI generation so the creator
/// doesn't re-answer the same questions each time.
class ChannelProfile {
  const ChannelProfile({
    this.niche = '',
    this.audience = '',
    this.language,
    this.tone,
    this.styleNotes = '',
  });

  /// What the channel is about, e.g. "Hindi street-food cooking".
  final String niche;

  /// Who typically watches, e.g. "18–30 foodies in tier-2 cities".
  final String audience;

  /// The creator's preferred output language (null = not chosen).
  final Language? language;

  /// The creator's preferred tone (null = not chosen).
  final Tone? tone;

  /// Free-form notes about the creator's speaking style.
  final String styleNotes;

  /// A profile is "set" once at least one meaningful field is filled.
  bool get isNotEmpty =>
      niche.trim().isNotEmpty ||
      audience.trim().isNotEmpty ||
      styleNotes.trim().isNotEmpty ||
      language != null ||
      tone != null;

  bool get isEmpty => !isNotEmpty;

  ChannelProfile copyWith({
    String? niche,
    String? audience,
    Language? language,
    Tone? tone,
    String? styleNotes,
  }) {
    return ChannelProfile(
      niche: niche ?? this.niche,
      audience: audience ?? this.audience,
      language: language ?? this.language,
      tone: tone ?? this.tone,
      styleNotes: styleNotes ?? this.styleNotes,
    );
  }

  /// Short summary for list tiles, e.g. "Cooking · Hindi · Casual".
  String get summary {
    final parts = <String>[];
    final n = niche.trim();
    if (n.isNotEmpty) parts.add(n);
    if (language != null) parts.add(language!.name);
    if (tone != null) parts.add(tone!.label);
    return parts.join(' · ');
  }
}

/// Serialization helpers for the Hive settings box (plain strings/ints only).
extension ChannelProfileStorage on ChannelProfile {
  Map<String, Object?> toStorageMap() {
    return {
      'niche': niche.trim(),
      'audience': audience.trim(),
      'languageCode': language?.code,
      'toneLabel': tone?.label,
      'styleNotes': styleNotes.trim(),
    };
  }
}

/// Deserialization from the Hive settings box (plain strings only).
ChannelProfile channelProfileFromStorageMap(Map<Object?, Object?> map) {
  final languageCode = map['languageCode'] as String?;
  final toneLabel = map['toneLabel'] as String?;
  return ChannelProfile(
    niche: (map['niche'] as String?) ?? '',
    audience: (map['audience'] as String?) ?? '',
    language: languageCode == null ? null : LanguageCatalog.byCode(languageCode),
    tone: toneLabel == null ? null : ToneCatalog.byLabel(toneLabel),
    styleNotes: (map['styleNotes'] as String?) ?? '',
  );
}
