import 'package:flutter/foundation.dart';

/// The output of the Title Generator feature.
@immutable
class GeneratedTitle {
  const GeneratedTitle({
    required this.id,
    required this.topic,
    required this.language,
    required this.titles,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String language;
  final List<String> titles;
  final DateTime createdAt;

  /// Creates a [GeneratedTitle] from parsed AI JSON.
  factory GeneratedTitle.fromAiJson({
    required String id,
    required String topic,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final list = json['titles'] as List<dynamic>? ?? [];
    return GeneratedTitle(
      id: id,
      topic: topic,
      language: language,
      titles: list.cast<String>(),
      createdAt: createdAt,
    );
  }

  /// Serializes to JSON for history storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'language': language,
        'titles': titles,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Deserializes from history storage JSON.
  factory GeneratedTitle.fromJson(Map<String, dynamic> json) {
    return GeneratedTitle(
      id: json['id'] as String,
      topic: json['topic'] as String,
      language: json['language'] as String,
      titles: (json['titles'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// A single string for sharing.
  String get shareText => titles.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');

  @override
  String toString() => 'GeneratedTitle(topic: $topic, count: ${titles.length})';
}
