import 'package:flutter/foundation.dart';

@immutable
class ChapterItem {
  const ChapterItem({required this.time, required this.title});

  final String time;
  final String title;

  String get line => '$time $title';

  Map<String, dynamic> toJson() => {'time': time, 'title': title};

  factory ChapterItem.fromJson(Map<String, dynamic> json) {
    return ChapterItem(
      time: json['time'] as String? ?? '0:00',
      title: json['title'] as String? ?? '',
    );
  }
}

@immutable
class GeneratedChapters {
  const GeneratedChapters({
    required this.id,
    required this.topic,
    required this.language,
    required this.durationLabel,
    required this.chapters,
    required this.createdAt,
    this.descriptionBlock = '',
  });

  final String id;
  final String topic;
  final String language;
  final String durationLabel;
  final List<ChapterItem> chapters;
  final String descriptionBlock;
  final DateTime createdAt;

  List<String> get lines => chapters.map((c) => c.line).toList();

  factory GeneratedChapters.fromAiJson({
    required String id,
    required String topic,
    required String language,
    required String durationLabel,
    required Map<String, dynamic> json,
    required DateTime createdAt,
  }) {
    final raw = json['chapters'] as List<dynamic>? ?? [];
    final chapters = raw
        .whereType<Map>()
        .map((e) => ChapterItem.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.title.trim().isNotEmpty)
        .toList();

    var block = json['descriptionBlock'] as String? ?? '';
    if (block.trim().isEmpty && chapters.isNotEmpty) {
      block = chapters.map((c) => c.line).join('\n');
    }

    return GeneratedChapters(
      id: id,
      topic: topic,
      language: language,
      durationLabel: durationLabel,
      chapters: chapters,
      descriptionBlock: block,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'language': language,
        'durationLabel': durationLabel,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'descriptionBlock': descriptionBlock,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GeneratedChapters.fromJson(Map<String, dynamic> json) {
    final raw = json['chapters'] as List<dynamic>? ?? [];
    return GeneratedChapters(
      id: json['id'] as String,
      topic: json['topic'] as String,
      language: json['language'] as String,
      durationLabel: json['durationLabel'] as String? ?? '',
      chapters: raw
          .map((e) => ChapterItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      descriptionBlock: json['descriptionBlock'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get shareText =>
      descriptionBlock.trim().isNotEmpty ? descriptionBlock : lines.join('\n');
}
