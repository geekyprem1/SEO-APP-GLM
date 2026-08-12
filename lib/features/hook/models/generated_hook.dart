import 'package:flutter/foundation.dart';

import '../../../core/utils/json_utils.dart';

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
    return GeneratedHook(
      id: id,
      topic: topic,
      language: language,
      hooks: JsonUtils.stringList(json['hooks']),
      styleTips: JsonUtils.stringList(json['styleTips']),
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
      hooks: JsonUtils.stringList(json['hooks']),
      styleTips: JsonUtils.stringList(json['styleTips']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => hooks.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');
}
