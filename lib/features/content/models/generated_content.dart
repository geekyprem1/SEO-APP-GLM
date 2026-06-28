import 'package:flutter/foundation.dart';

/// The output of the Content Generator feature.
@immutable
class GeneratedContent {
  const GeneratedContent({
    required this.id,
    required this.topic,
    required this.hook,
    required this.mainContent,
    required this.cta,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String hook;
  final String mainContent;
  final String cta;
  final DateTime createdAt;

  factory GeneratedContent.fromAiJson({
    required String id,
    required String topic,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    return GeneratedContent(
      id: id,
      topic: topic,
      hook: json['hook'] as String? ?? '',
      mainContent: json['mainContent'] as String? ?? '',
      cta: json['cta'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'hook': hook,
        'mainContent': mainContent,
        'cta': cta,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedContent.fromJson(Map<String, dynamic> json) {
    return GeneratedContent(
      id: json['id'] as String,
      topic: json['topic'] as String,
      hook: json['hook'] as String,
      mainContent: json['mainContent'] as String,
      cta: json['cta'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => '''🎬 Hook
$hook

📝 Main Content
$mainContent

📣 Call to Action
$cta''';

  @override
  String toString() => 'GeneratedContent(topic: $topic)';
}
