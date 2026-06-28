import 'package:flutter/foundation.dart';

/// The output of the Trending Topics feature.
@immutable
class TrendingTopics {
  const TrendingTopics({
    required this.id,
    required this.category,
    required this.country,
    required this.language,
    required this.topics,
    required this.createdAt,
  });

  final String id;
  final String category;
  final String country;
  final String language;
  final List<String> topics;
  final DateTime createdAt;

  factory TrendingTopics.fromAiJson({
    required String id,
    required String category,
    required String country,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final list = json['topics'] as List<dynamic>? ?? [];
    return TrendingTopics(
      id: id,
      category: category,
      country: country,
      language: language,
      topics: list.cast<String>(),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'country': country,
        'language': language,
        'topics': topics,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TrendingTopics.fromJson(Map<String, dynamic> json) {
    return TrendingTopics(
      id: json['id'] as String,
      category: json['category'] as String,
      country: json['country'] as String,
      language: json['language'] as String,
      topics: (json['topics'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => topics.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');

  @override
  String toString() => 'TrendingTopics(category: $category, country: $country)';
}
