import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:short_seo_ai/features/content_studio/models/content_package.dart';
import 'package:short_seo_ai/features/projects/models/project.dart';
import 'package:short_seo_ai/features/projects/repository/project_repository.dart';
import 'package:short_seo_ai/shared/models/content_format.dart';

ContentPackage _package(String id, String topic) => ContentPackage(
      id: id,
      topic: topic,
      format: ContentFormat.shorts,
      language: 'English',
      tone: 'Casual',
      duration: 'Under 60 seconds',
      titles: ['Title 1'],
      hook: 'Hook!',
      script: 'Script body',
      description: 'Description',
      keywords: ['food'],
      hashtags: ['#food'],
      thumbnailTextIdeas: ['MAGGI'],
      cta: 'Subscribe',
      createdAt: DateTime(2026, 11, 6),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box box;
  late ProjectRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('projects_test');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    box = await Hive.openBox('projects_test_${DateTime.now().microsecondsSinceEpoch}');
    repository = ProjectRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  group('ProjectStatus', () {
    test('workflow order draft → ready → published', () {
      expect(ProjectStatus.draft.next, ProjectStatus.ready);
      expect(ProjectStatus.ready.next, ProjectStatus.published);
      expect(ProjectStatus.published.next, isNull);
    });

    test('byName falls back to draft for unknown values', () {
      expect(ProjectStatus.byName('ready'), ProjectStatus.ready);
      expect(ProjectStatus.byName('bogus'), ProjectStatus.draft);
      expect(ProjectStatus.byName(null), ProjectStatus.draft);
    });
  });

  group('Project JSON round-trip', () {
    test('preserves every field', () {
      final project = Project(
        id: 'p1',
        status: ProjectStatus.ready,
        packageJson: _package('p1', 'Maggi hacks').toJson(),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 11, 6, 12),
        publishedAt: null,
      );

      final restored = Project.fromJson(project.toJson());

      expect(restored.id, 'p1');
      expect(restored.status, ProjectStatus.ready);
      expect(restored.topic, 'Maggi hacks');
      expect(restored.package.script, 'Script body');
      expect(restored.createdAt, project.createdAt);
      expect(restored.updatedAt, project.updatedAt);
      expect(restored.publishedAt, isNull);
      expect(restored.isInProgress, isTrue);
    });

    test('published project stamps publishedAt and is not in progress', () {
      final project = Project(
        id: 'p2',
        status: ProjectStatus.published,
        packageJson: _package('p2', 'Done').toJson(),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 11, 6),
        publishedAt: DateTime(2026, 11, 5),
      );

      final restored = Project.fromJson(project.toJson());
      expect(restored.isInProgress, isFalse);
      expect(restored.publishedAt, DateTime(2026, 11, 5));
    });
  });

  group('ProjectRepository', () {
    test('upsert creates a draft, then updates it keeping status', () async {
      final package = _package('a1', 'Street food tour');
      await repository.upsertFromPackage(package);

      final created = repository.getById('a1')!;
      expect(created.status, ProjectStatus.draft);
      expect(created.topic, 'Street food tour');

      // Advance to ready, then save the package again — status must survive.
      await repository.setStatus('a1', ProjectStatus.ready);
      final edited = _package('a1', 'Street food tour (edited)');
      await repository.upsertFromPackage(edited);

      final updated = repository.getById('a1')!;
      expect(updated.status, ProjectStatus.ready,
          reason: 're-saving a package must not reset its workflow status');
      expect(updated.topic, 'Street food tour (edited)');
    });

    test('getAll sorts drafts first, then ready, published last', () async {
      await repository.upsertFromPackage(_package('pub', 'Old'));
      await repository.setStatus('pub', ProjectStatus.published);

      await repository.upsertFromPackage(_package('rdy', 'Ready one'));
      await repository.setStatus('rdy', ProjectStatus.ready);

      await repository.upsertFromPackage(_package('drf', 'Fresh draft'));

      final all = repository.getAll();
      expect(all.map((p) => p.id).toList(), ['drf', 'rdy', 'pub']);
    });

    test('setStatus to published stamps publishedAt', () async {
      await repository.upsertFromPackage(_package('x', 'Topic'));
      await repository.setStatus('x', ProjectStatus.published);

      final project = repository.getById('x')!;
      expect(project.status, ProjectStatus.published);
      expect(project.publishedAt, isNotNull);
    });

    test('updatePackage keeps the status, replaces the content', () async {
      await repository.upsertFromPackage(_package('u1', 'Before'));
      await repository.setStatus('u1', ProjectStatus.ready);

      await repository.updatePackage('u1', _package('u1', 'After'));

      final project = repository.getById('u1')!;
      expect(project.status, ProjectStatus.ready);
      expect(project.topic, 'After');
    });

    test('delete removes the project', () async {
      await repository.upsertFromPackage(_package('d1', 'Bye'));
      await repository.delete('d1');
      expect(repository.getById('d1'), isNull);
    });
  });
}
