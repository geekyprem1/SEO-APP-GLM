import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../content_studio/models/content_package.dart';
import '../models/project.dart';

/// Provider for the projects Hive box.
/// Must be overridden in main.dart with an opened (encrypted) box.
final projectsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
      'Override in main.dart with the opened projects box.');
});

/// Persists [Project]s in their own encrypted Hive box.
///
/// Projects are keyed by the ContentPackage id — saving the same package
/// again (from the Content Studio or a project detail) updates the existing
/// project instead of duplicating it. Status survives edits.
class ProjectRepository {
  ProjectRepository(this._box);

  final Box _box;

  /// All projects: in-progress first (draft before ready), each group by
  /// most-recently-updated.
  List<Project> getAll() {
    final projects = _box.values
        .map((raw) =>
            raw is Map ? Project.fromJson(Map<dynamic, dynamic>.from(raw)) : null)
        .whereType<Project>()
        .toList();

    int statusRank(Project p) => switch (p.status) {
          ProjectStatus.draft => 0,
          ProjectStatus.ready => 1,
          ProjectStatus.published => 2,
        };

    projects.sort((a, b) {
      final byStatus = statusRank(a).compareTo(statusRank(b));
      if (byStatus != 0) return byStatus;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return projects;
  }

  Project? getById(String id) {
    final raw = _box.get(id);
    if (raw is! Map) return null;
    return Project.fromJson(Map<dynamic, dynamic>.from(raw));
  }

  /// Creates a draft project for [package], or refreshes an existing one
  /// (keeping its status). Called whenever a package is saved.
  Future<void> upsertFromPackage(ContentPackage package) async {
    final existing = getById(package.id);
    final now = DateTime.now();
    final project = Project(
      id: package.id,
      status: existing?.status ?? ProjectStatus.draft,
      packageJson: package.toJson(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      publishedAt: existing?.publishedAt,
    );
    await _box.put(package.id, project.toJson());
  }

  /// Overwrites the stored package payload, keeping the current status.
  Future<void> updatePackage(String id, ContentPackage package) async {
    final existing = getById(id);
    if (existing == null) return;
    await _box.put(
      id,
      existing
          .copyWith(
            packageJson: package.toJson(),
            updatedAt: DateTime.now(),
          )
          .toJson(),
    );
  }

  /// Moves a project to [status]; setting [ProjectStatus.published] stamps
  /// the publish time.
  Future<void> setStatus(String id, ProjectStatus status) async {
    final existing = getById(id);
    if (existing == null) return;
    await _box.put(
      id,
      existing
          .copyWith(
            status: status,
            updatedAt: DateTime.now(),
            publishedAt: status == ProjectStatus.published
                ? DateTime.now()
                : existing.publishedAt,
          )
          .toJson(),
    );
  }

  Future<void> delete(String id) => _box.delete(id);
}

/// Provider for the [ProjectRepository].
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(projectsBoxProvider));
});

/// Emits on every write to the projects box so dependent providers rebuild.
final _boxEventsProvider = StreamProvider<BoxEvent>((ref) {
  final box = ref.watch(projectsBoxProvider);
  return box.watch();
});

/// Live list of all projects, sorted for display.
final projectsProvider = Provider<List<Project>>((ref) {
  // Watch the box event stream so adds/edits/status changes rebuild this.
  ref.watch(_boxEventsProvider);
  return ref.watch(projectRepositoryProvider).getAll();
});

/// A single project by id, or null.
final projectByIdProvider =
    Provider.family<Project?, String>((ref, id) {
  ref.watch(_boxEventsProvider);
  return ref.watch(projectRepositoryProvider).getById(id);
});
