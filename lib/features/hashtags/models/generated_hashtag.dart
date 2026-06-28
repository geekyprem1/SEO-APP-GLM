import 'package:flutter/foundation.dart';

/// The output of the Hashtag Generator feature.
@immutable
class GeneratedHashtag {
  const GeneratedHashtag({
    required this.id,
    required this.topic,
    required this.hashtags,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final List<String> hashtags;
  final DateTime createdAt;

  factory GeneratedHashtag.fromAiJson({
    required String id,
    required String topic,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final list = json['hashtags'] as List<dynamic>? ?? [];
    return GeneratedHashtag(
      id: id,
      topic: topic,
      hashtags: list.cast<String>(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'hashtags': hashtags,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedHashtag.fromJson(Map<String, dynamic> json) {
    return GeneratedHashtag(
      id: json['id'] as String,
      topic: json['topic'] as String,
      hashtags: (json['hashtags'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => hashtags.map((h) => h.startsWith('#') ? h : '#$h').join(' ');

  @override
  String toString() => 'GeneratedHashtag(topic: $topic, count: ${hashtags.length})';
}
