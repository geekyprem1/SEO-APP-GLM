import 'package:flutter/foundation.dart';

/// The style of thumbnail to generate.
enum ThumbnailStyle {
  vibrant('Vibrant', 'bold colors, high contrast, eye-catching'),
  minimal('Minimal', 'clean, simple, lots of negative space'),
  cinematic('Cinematic', 'dramatic lighting, film-like, moody'),
  cartoon('Cartoon', 'animated, playful, illustrated style'),
  realistic('Realistic', 'photorealistic, professional photography');

  const ThumbnailStyle(this.label, this.description);
  final String label;
  final String description;
}

/// The output of the Thumbnail Generator feature.
@immutable
class GeneratedThumbnail {
  const GeneratedThumbnail({
    required this.id,
    required this.topic,
    required this.category,
    required this.style,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String category;
  final String style;
  final String imageUrl;
  final DateTime createdAt;

  factory GeneratedThumbnail.fromResult({
    required String id,
    required String topic,
    required String category,
    required String style,
    required String imageUrl,
    required DateTime createdAt,
  }) {
    return GeneratedThumbnail(
      id: id,
      topic: topic,
      category: category,
      style: style,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'category': category,
        'style': style,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedThumbnail.fromJson(Map<String, dynamic> json) {
    return GeneratedThumbnail(
      id: json['id'] as String,
      topic: json['topic'] as String,
      category: json['category'] as String,
      style: json['style'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() => 'GeneratedThumbnail(topic: $topic, style: $style)';
}
