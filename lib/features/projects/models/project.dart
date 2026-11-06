import 'package:flutter/foundation.dart';

import '../../content_studio/models/content_package.dart';

/// The workflow status of a saved project.
///
/// Growth findings (P1): a creator's work on one video moves through
/// Draft → Ready → Published, so an unfinished video gives them a reason
/// to return and a finished one a sense of progress.
enum ProjectStatus {
  draft('Draft'),
  ready('Ready'),
  published('Published');

  const ProjectStatus(this.label);

  final String label;

  static ProjectStatus byName(String? name) {
    return ProjectStatus.values.firstWhere(
      (s) => s.name == name,
      orElse: () => ProjectStatus.draft,
    );
  }

  /// The next status in the workflow, or null when already published.
  ProjectStatus? get next => switch (this) {
        ProjectStatus.draft => ProjectStatus.ready,
        ProjectStatus.ready => ProjectStatus.published,
        ProjectStatus.published => null,
      };
}

/// One video as a working project — the saved [ContentPackage] plus its
/// place in the Draft → Ready → Published workflow.
///
/// The project id is the package id, so saving the same package again
/// updates the existing project instead of creating a duplicate.
@immutable
class Project {
  const Project({
    required this.id,
    required this.status,
    required this.packageJson,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  final String id;
  final ProjectStatus status;

  /// The stored [ContentPackage] payload (its `toJson` form).
  final Map<String, dynamic> packageJson;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  ContentPackage get package => ContentPackage.fromJson(packageJson);

  String get topic => package.topic;

  bool get isInProgress => status != ProjectStatus.published;

  Project copyWith({
    ProjectStatus? status,
    Map<String, dynamic>? packageJson,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return Project(
      id: id,
      status: status ?? this.status,
      packageJson: packageJson ?? this.packageJson,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status.name,
        'package': packageJson,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (publishedAt != null)
          'publishedAt': publishedAt!.toIso8601String(),
      };

  factory Project.fromJson(Map<dynamic, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      status: ProjectStatus.byName(json['status'] as String?),
      packageJson:
          Map<String, dynamic>.from(json['package'] as Map? ?? const {}),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
              DateTime.now(),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.tryParse(json['publishedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Project && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
