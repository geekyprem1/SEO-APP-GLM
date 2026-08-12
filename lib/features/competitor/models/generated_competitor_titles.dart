import 'package:flutter/foundation.dart';

@immutable
class GeneratedCompetitorTitles {
  const GeneratedCompetitorTitles({
    required this.id,
    required this.sourceTitle,
    required this.language,
    required this.titles,
    required this.createdAt,
  });

  final String id;
  final String sourceTitle;
  final String language;
  final List<String> titles;
  final DateTime createdAt;

  factory GeneratedCompetitorTitles.fromAiJson({
    required String id,
    required String sourceTitle,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    return GeneratedCompetitorTitles(
      id: id,
      sourceTitle: sourceTitle,
      language: language,
      titles: (json['titles'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceTitle': sourceTitle,
        'language': language,
        'titles': titles,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedCompetitorTitles.fromJson(Map<String, dynamic> json) {
    return GeneratedCompetitorTitles(
      id: json['id'] as String,
      sourceTitle: json['sourceTitle'] as String,
      language: json['language'] as String,
      titles: (json['titles'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => titles.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');
}
