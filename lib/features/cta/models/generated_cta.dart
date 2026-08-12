import 'package:flutter/foundation.dart';

@immutable
class GeneratedCta {
  const GeneratedCta({
    required this.id,
    required this.topic,
    required this.language,
    required this.ctas,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String language;
  final List<String> ctas;
  final DateTime createdAt;

  factory GeneratedCta.fromAiJson({
    required String id,
    required String topic,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final list = (json['ctas'] as List<dynamic>? ?? []).cast<String>();
    return GeneratedCta(
      id: id,
      topic: topic,
      language: language,
      ctas: list,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'language': language,
        'ctas': ctas,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedCta.fromJson(Map<String, dynamic> json) {
    return GeneratedCta(
      id: json['id'] as String,
      topic: json['topic'] as String,
      language: json['language'] as String,
      ctas: (json['ctas'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => ctas.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');
}
