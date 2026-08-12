import 'package:flutter/foundation.dart';

@immutable
class SeriesIdea {
  const SeriesIdea({required this.title, this.angle});

  final String title;
  final String? angle;

  String get line =>
      angle == null || angle!.trim().isEmpty ? title : '$title — $angle';

  Map<String, dynamic> toJson() => {
        'title': title,
        if (angle != null) 'angle': angle,
      };

  factory SeriesIdea.fromJson(Map<String, dynamic> json) {
    return SeriesIdea(
      title: json['title'] as String? ?? '',
      angle: json['angle'] as String?,
    );
  }
}

@immutable
class GeneratedSeries {
  const GeneratedSeries({
    required this.id,
    required this.topic,
    required this.language,
    required this.ideas,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String language;
  final List<SeriesIdea> ideas;
  final DateTime createdAt;

  List<String> get lines => ideas.map((i) => i.line).toList();

  factory GeneratedSeries.fromAiJson({
    required String id,
    required String topic,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final raw = json['ideas'] as List<dynamic>? ?? [];
    final ideas = raw.map((e) {
      if (e is String) return SeriesIdea(title: e);
      if (e is Map) {
        return SeriesIdea.fromJson(Map<String, dynamic>.from(e));
      }
      return const SeriesIdea(title: '');
    }).where((i) => i.title.trim().isNotEmpty).toList();

    return GeneratedSeries(
      id: id,
      topic: topic,
      language: language,
      ideas: ideas,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'language': language,
        'ideas': ideas.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedSeries.fromJson(Map<String, dynamic> json) {
    final raw = json['ideas'] as List<dynamic>? ?? [];
    return GeneratedSeries(
      id: json['id'] as String,
      topic: json['topic'] as String,
      language: json['language'] as String,
      ideas: raw
          .map((e) => SeriesIdea.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => lines.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');
}
