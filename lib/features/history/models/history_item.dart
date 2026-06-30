import 'package:hive/hive.dart';

part 'history_item.g.dart';

/// Identifies which feature produced a history entry.
@HiveType(typeId: 0)
enum HistoryType {
  @HiveField(0)
  title,
  @HiveField(1)
  hashtag,
  @HiveField(2)
  description,
  @HiveField(3)
  content,
  @HiveField(4)
  viralIdeas,
  @HiveField(5)
  trending,
  @HiveField(6)
  thumbnail,
  @HiveField(7)
  seo,
}

/// Polymorphic history entry stored in Hive.
///
/// Stores the serialized model JSON in [data] to avoid complex polymorphic
/// Hive adapters. The repository rehydrates the concrete model from
/// [type] + [data] when opening a detail screen.
@HiveType(typeId: 1)
class HistoryItem extends HiveObject {
  HistoryItem({
    required this.id,
    required this.type,
    required this.displayTitle,
    required this.data,
    required this.createdAt,
  });

  HistoryItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        type = HistoryType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => HistoryType.title,
        ),
        displayTitle = json['displayTitle'] as String,
        data = Map<String, dynamic>.from(json['data'] as Map),
        createdAt = DateTime.parse(json['createdAt'] as String);

  @HiveField(0)
  final String id;

  @HiveField(1)
  final HistoryType type;

  @HiveField(2)
  final String displayTitle;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'displayTitle': displayTitle,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() => 'HistoryItem($type: $displayTitle)';
}
