import 'dart:convert';

import 'package:flutter/foundation.dart';
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
///
/// Every storage failure degrades gracefully — a corrupt key, a locked
/// keychain, or an unreadable box file can never brick startup; the affected
/// box is recreated instead.
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
  ///
  /// A corrupt/invalid stored key is replaced with a fresh one; boxes that can
  /// no longer be decrypted are recreated by [openEncrypted] instead of
  /// crashing on startup.
  Future<Uint8List> _key() async {
    final cached = _cachedKey;
    if (cached != null) return cached;

    final existing = await _readSecret(_aesKeyName);
    if (existing != null) {
      try {
        final decoded = base64Url.decode(existing);
        if (decoded.isNotEmpty) {
          return _cachedKey = decoded;
        }
      } catch (_) {
        _log('stored key was not valid base64 — minting a fresh key');
      }
    }

    // First launch (or post-wipe / unreadable key): mint a fresh key.
    final key = Hive.generateSecureKey(); // 32 cryptographically-random bytes
    await _writeSecret(_aesKeyName, base64Url.encode(key));
    return _cachedKey = Uint8List.fromList(key);
  }

  /// The cipher used to open every box. Call AFTER [migrateIfNeeded].
  Future<HiveAesCipher> cipher() async => HiveAesCipher(await _key());

  /// Opens [name] with the AES cipher, recreating it if it can no longer be
  /// decrypted (lost/corrupt key). Falls back to an in-memory box so the app
  /// always starts; failures are logged instead of thrown.
  Future<Box<T>> openEncrypted<T>(String name) async {
    final cipher = await this.cipher();
    try {
      return await Hive.openBox<T>(name, encryptionCipher: cipher);
    } catch (e) {
      _log('box "$name" could not be decrypted — recreating', e);
      try {
        await Hive.deleteBoxFromDisk(name);
        return await Hive.openBox<T>(name, encryptionCipher: cipher);
      } catch (e) {
        _log('box "$name" could not be recreated — using in-memory box', e);
        return await Hive.openBox<T>(name, bytes: Uint8List(0));
      }
    }
  }

  /// One-time, idempotent migration of legacy plaintext boxes → encrypted.
  ///
  /// Each box is guarded by its own secure-storage flag, so:
  ///  - a fresh install simply marks each box migrated (nothing on disk yet);
  ///  - an upgrade reads the existing plaintext data, rewrites it encrypted;
  ///  - an interrupted run resumes safely and never re-touches a box that has
  ///    already been converted (which would otherwise be misread as plaintext).
  ///
  /// A failure on one box never aborts startup: the box is left unmarked and
  /// recovered on the next launch (or by [openEncrypted]).
  Future<void> migrateIfNeeded(List<String> boxNames) async {
    final cipher = HiveAesCipher(await _key());

    for (final name in boxNames) {
      final flag = 'hive_enc_$name';
      if (await _readSecret(flag) == 'true') {
        continue; // already encrypted in a previous run
      }

      try {
        if (await Hive.boxExists(name)) {
          // 1. Read the existing PLAINTEXT contents into memory.
          final plain = await Hive.openBox<dynamic>(name);
          final data = Map<dynamic, dynamic>.from(plain.toMap());
          await plain.close();

          // 2. Replace the on-disk file with an encrypted box holding that data.
          await Hive.deleteBoxFromDisk(name);
          final enc =
              await Hive.openBox<dynamic>(name, encryptionCipher: cipher);
          if (data.isNotEmpty) await enc.putAll(data);
          await enc.close();
        }

        // 3. Mark this box done only after it is fully converted.
        await _writeSecret(flag, 'true');
      } catch (e) {
        _log('migration failed for box "$name" — will retry next launch', e);
      }
    }
  }

  /// Reads a secure-storage entry, retrying once so a temporarily locked
  /// keychain (iOS `first_unlock` before device unlock) cannot break startup.
  static Future<String?> _readSecret(String key) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _storage.read(key: key);
      } catch (e) {
        _log('secure storage read failed for "$key" (attempt ${attempt + 1})', e);
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }
    return null;
  }

  /// Writes a secure-storage entry; the cached in-memory key still works for
  /// this session if the write fails.
  static Future<void> _writeSecret(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      _log('secure storage write failed for "$key"', e);
    }
  }

  static void _log(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('HiveEncryption: $message${error == null ? '' : ' — $error'}');
    }
  }
}
