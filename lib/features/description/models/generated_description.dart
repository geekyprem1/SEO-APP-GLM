import 'package:flutter/foundation.dart';

/// The output of the Description Generator feature.
@immutable
class GeneratedDescription {
  const GeneratedDescription({
    required this.id,
    required this.topic,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String description;
  final DateTime createdAt;

  factory GeneratedDescription.fromAiJson({
    required String id,
    required String topic,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    return GeneratedDescription(
      id: id,
      topic: topic,
      description: json['description'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedDescription.fromJson(Map<String, dynamic> json) {
    return GeneratedDescription(
      id: json['id'] as String,
      topic: json['topic'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => description;

  @override
  String toString() => 'GeneratedDescription(topic: $topic)';
}
