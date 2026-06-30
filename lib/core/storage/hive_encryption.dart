import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralizes encryption-at-rest for every Hive box.
///
/// - A single 256-bit AES key is generated once with [Hive.generateSecureKey]
///   (a CSPRNG) and persisted in the platform secure store via
///   flutter_secure_storage — Android Keystore-backed EncryptedSharedPreferences
///   and the iOS Keychain. The key never touches Hive's own files.
/// - Every box is opened with a [HiveAesCipher] built from that key.
/// - On upgrade from an older (plaintext) build, each existing box is migrated
///   in place to encrypted form with no data loss. See [migrateIfNeeded].
class HiveEncryption {
  HiveEncryption._();

  /// Singleton — the AES key is cached in memory after the first read.
  static final HiveEncryption instance = HiveEncryption._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Secure-storage entry under which the base64 AES key is kept.
  static const String _aesKeyName = 'hive_aes_key_v1';

  Uint8List? _cachedKey;

  /// Returns the AES key, generating + persisting it on first launch.
  Future<Uint8List> _key() async {
    final cached = _cachedKey;
    if (cached != null) return cached;

    final existing = await _storage.read(key: _aesKeyName);
    if (existing != null) {
      return _cachedKey = base64Url.decode(existing);
    }

    // First launch (or post-wipe): mint a fresh key and store it securely.
    final key = Hive.generateSecureKey(); // 32 cryptographically-random bytes
    await _storage.write(key: _aesKeyName, value: base64Url.encode(key));
    return _cachedKey = Uint8List.fromList(key);
  }

  /// The cipher used to open every box. Call AFTER [migrateIfNeeded].
  Future<HiveAesCipher> cipher() async => HiveAesCipher(await _key());

  /// One-time, idempotent migration of legacy plaintext boxes → encrypted.
  ///
  /// Each box is guarded by its own secure-storage flag, so:
  ///  - a fresh install simply marks each box migrated (nothing on disk yet);
  ///  - an upgrade reads the existing plaintext data, rewrites it encrypted;
  ///  - an interrupted run resumes safely and never re-touches a box that has
  ///    already been converted (which would otherwise be misread as plaintext).
  Future<void> migrateIfNeeded(List<String> boxNames) async {
    final cipher = HiveAesCipher(await _key());

    for (final name in boxNames) {
      final flag = 'hive_enc_$name';
      if (await _storage.read(key: flag) == 'true') {
        continue; // already encrypted in a previous run
      }

      if (await Hive.boxExists(name)) {
        // 1. Read the existing PLAINTEXT contents into memory.
        final plain = await Hive.openBox<dynamic>(name);
        final data = Map<dynamic, dynamic>.from(plain.toMap());
        await plain.close();

        // 2. Replace the on-disk file with an encrypted box holding that data.
        await Hive.deleteBoxFromDisk(name);
        final enc = await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
        if (data.isNotEmpty) await enc.putAll(data);
        await enc.close();
      }

      // 3. Mark this box done only after it is fully converted.
      await _storage.write(key: flag, value: 'true');
    }
  }
}
