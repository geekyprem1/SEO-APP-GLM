import 'package:flutter/foundation.dart';

/// The output of the Viral Shorts Ideas feature.
@immutable
class ViralIdeas {
  const ViralIdeas({
    required this.id,
    required this.category,
    required this.language,
    required this.ideas,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String language;
  final List<String> ideas;
  final DateTime createdAt;

  factory ViralIdeas.fromAiJson({
    required String id,
    required String category,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final list = json['ideas'] as List<dynamic>? ?? [];
    return ViralIdeas(
      id: id,
      category: category,
      language: language,
      ideas: list.cast<String>(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'language': language,
        'ideas': ideas,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ViralIdeas.fromJson(Map<String, dynamic> json) {
    return ViralIdeas(
      id: json['id'] as String,
      category: json['category'] as String,
      language: json['language'] as String,
      ideas: (json['ideas'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => ideas.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');

  @override
  String toString() => 'ViralIdeas(category: $category, count: ${ideas.length})';
}
