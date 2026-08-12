import 'package:flutter/foundation.dart';

@immutable
class CaptionLine {
  const CaptionLine({required this.text, this.beats});

  final String text;
  final String? beats;

  Map<String, dynamic> toJson() => {
        'text': text,
        if (beats != null) 'beats': beats,
      };

  factory CaptionLine.fromJson(Map<String, dynamic> json) {
    return CaptionLine(
      text: json['text'] as String? ?? '',
      beats: json['beats'] as String?,
    );
  }
}

@immutable
class GeneratedCaptions {
  const GeneratedCaptions({
    required this.id,
    required this.topic,
    required this.language,
    required this.captions,
    required this.createdAt,
  });

  final String id;
  final String topic;
  final String language;
  final List<CaptionLine> captions;
  final DateTime createdAt;

  List<String> get lines =>
      captions.map((c) => c.text).where((t) => t.trim().isNotEmpty).toList();

  factory GeneratedCaptions.fromAiJson({
    required String id,
    required String topic,
    required String language,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final raw = json['captions'] as List<dynamic>? ?? [];
    final captions = raw.map((e) {
      if (e is String) return CaptionLine(text: e);
      if (e is Map) {
        return CaptionLine.fromJson(Map<String, dynamic>.from(e));
      }
      return const CaptionLine(text: '');
    }).where((c) => c.text.trim().isNotEmpty).toList();

    return GeneratedCaptions(
      id: id,
      topic: topic,
      language: language,
      captions: captions,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'language': language,
        'captions': captions.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedCaptions.fromJson(Map<String, dynamic> json) {
    final raw = json['captions'] as List<dynamic>? ?? [];
    return GeneratedCaptions(
      id: json['id'] as String,
      topic: json['topic'] as String,
      language: json['language'] as String,
      captions: raw
          .map((e) => CaptionLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText => lines.asMap().entries.map((e) {
        return '${e.key + 1}. ${e.value}';
      }).join('\n');
}
