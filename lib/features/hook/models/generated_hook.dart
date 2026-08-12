import 'package:flutter/foundation.dart';

/// Output of the Hook Generator feature.
@immutable
class GeneratedHook {
  const GeneratedHook({
    required this.id,
    required this.topic,
    required this.language,
    required this.hooks,
    required this.createdAt,
    this.styleTips = const [],
  });

  final String id;
  final String topic;
  final String language;
  final List<String> hooks;
  final List<String> styleTips;
  final DateTime createdAt;

  factory GeneratedHook.fromAiJson({
    required String id,
    required String topic,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final hooks = (json['hooks'] as List<dynamic>? ?? []).cast<String>();
    final tips = (json['styleTips'] as List<dynamic>? ?? []).cast<String>();
    return GeneratedHook(
      id: id,
      topic: topic,
      language: language,
      hooks: hooks,
      styleTips: tips,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'language': language,
        'hooks': hooks,
        'styleTips': styleTips,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedHook.fromJson(Map<String, dynamic> json) {
    return GeneratedHook(
      id: json['id'] as String,
      topic: json['topic'] as String,
      language: json['language'] as String,
      hooks: (json['hooks'] as List<dynamic>).cast<String>(),
      styleTips: (json['styleTips'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => hooks.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');
}
