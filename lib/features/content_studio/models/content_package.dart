import 'package:flutter/foundation.dart';

import '../../../shared/models/content_format.dart';

/// The all-in-one output of the AI Content Studio.
///
/// Bundles every element a Creator needs to publish a YouTube Short or Video:
/// title options, a first-three-seconds hook, a script, an SEO description,
/// keywords, hashtags, thumbnail text ideas, and a call to action.
///
/// Every field is individually editable in the UI; edits produce a new
/// instance via [copyWith].
@immutable
class ContentPackage {
  const ContentPackage({
    required this.id,
    required this.topic,
    required this.format,
    required this.language,
    required this.tone,
    required this.duration,
    required this.titles,
    required this.hook,
    required this.script,
    required this.description,
    required this.keywords,
    required this.hashtags,
    required this.thumbnailTextIdeas,
    required this.cta,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final ContentFormat format;
  final String language;
  final String tone;
  final String duration;
  final List<String> titles;
  final String hook;
  final String script;
  final String description;
  final List<String> keywords;
  final List<String> hashtags;
  final List<String> thumbnailTextIdeas;
  final String cta;
  final DateTime createdAt;

  ContentPackage copyWith({
    List<String>? titles,
    String? hook,
    String? script,
    String? description,
    List<String>? keywords,
    List<String>? hashtags,
    List<String>? thumbnailTextIdeas,
    String? cta,
  }) {
    return ContentPackage(
      id: id,
      topic: topic,
      format: format,
      language: language,
      tone: tone,
      duration: duration,
      titles: titles ?? this.titles,
      hook: hook ?? this.hook,
      script: script ?? this.script,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      hashtags: hashtags ?? this.hashtags,
      thumbnailTextIdeas: thumbnailTextIdeas ?? this.thumbnailTextIdeas,
      cta: cta ?? this.cta,
      createdAt: createdAt,
    );
  }

  /// Defensively coerces an AI/JSON value into a clean list of strings.
  /// Accepts a JSON list, or a newline/comma separated string.
  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value
          .split(RegExp(r'[\n,]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static String _string(dynamic value) =>
      value is String ? value.trim() : (value?.toString().trim() ?? '');

  /// Builds a package from the AI's structured JSON response.
  factory ContentPackage.fromAiJson({
    required String id,
    required String topic,
    required ContentFormat format,
    required String language,
    required String tone,
    required String duration,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    return ContentPackage(
      id: id,
      topic: topic,
      format: format,
      language: language,
      tone: tone,
      duration: duration,
      titles: _stringList(json['titles']),
      hook: _string(json['hook']),
      script: _string(json['script']),
      description: _string(json['description']),
      keywords: _stringList(json['keywords']),
      hashtags: _stringList(json['hashtags']),
      thumbnailTextIdeas: _stringList(json['thumbnailTextIdeas']),
      cta: _string(json['cta']),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'format': format.name,
        'language': language,
        'tone': tone,
        'duration': duration,
        'titles': titles,
        'hook': hook,
        'script': script,
        'description': description,
        'keywords': keywords,
        'hashtags': hashtags,
        'thumbnailTextIdeas': thumbnailTextIdeas,
        'cta': cta,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContentPackage.fromJson(Map<String, dynamic> json) {
    ContentFormat resolveFormat(dynamic v) {
      final name = v?.toString();
      return ContentFormat.values.firstWhere(
        (f) => f.name == name,
        orElse: () => ContentFormat.shorts,
      );
    }

    return ContentPackage(
      id: json['id'] as String,
      topic: json['topic'] as String? ?? '',
      format: resolveFormat(json['format']),
      language: json['language'] as String? ?? '',
      tone: json['tone'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      titles: _stringList(json['titles']),
      hook: _string(json['hook']),
      script: _string(json['script']),
      description: _string(json['description']),
      keywords: _stringList(json['keywords']),
      hashtags: _stringList(json['hashtags']),
      thumbnailTextIdeas: _stringList(json['thumbnailTextIdeas']),
      cta: _string(json['cta']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// True when the AI returned nothing usable.
  bool get isEmpty =>
      titles.isEmpty &&
      hook.isEmpty &&
      script.isEmpty &&
      description.isEmpty &&
      cta.isEmpty;

  /// A shareable, human-readable rendering of the whole package.
  String get shareText {
    final buffer = StringBuffer();
    buffer.writeln('📌 ${topic.isEmpty ? 'Content Package' : topic}');
    buffer.writeln('(${format.label} • $duration • $tone • $language)');

    if (titles.isNotEmpty) {
      buffer.writeln('\n🎯 Titles');
      for (var i = 0; i < titles.length; i++) {
        buffer.writeln('${i + 1}. ${titles[i]}');
      }
    }
    if (hook.isNotEmpty) {
      buffer.writeln('\n⚡ Hook (first 3 seconds)\n$hook');
    }
    if (script.isNotEmpty) {
      buffer.writeln('\n🎬 Script\n$script');
    }
    if (description.isNotEmpty) {
      buffer.writeln('\n📝 Description\n$description');
    }
    if (keywords.isNotEmpty) {
      buffer.writeln('\n🔑 Keywords\n${keywords.join(', ')}');
    }
    if (hashtags.isNotEmpty) {
      buffer.writeln('\n#️⃣ Hashtags\n${hashtags.join(' ')}');
    }
    if (thumbnailTextIdeas.isNotEmpty) {
      buffer.writeln('\n🖼️ Thumbnail Text Ideas');
      for (final idea in thumbnailTextIdeas) {
        buffer.writeln('• $idea');
      }
    }
    if (cta.isNotEmpty) {
      buffer.writeln('\n📣 Call to Action\n$cta');
    }
    return buffer.toString().trim();
  }

  @override
  String toString() => 'ContentPackage(topic: $topic, format: ${format.name})';
}
