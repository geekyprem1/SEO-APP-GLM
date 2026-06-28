import 'package:flutter/foundation.dart';

/// Lightweight user representation for the auth layer.
/// Avoids coupling the UI to Firebase types directly.
@immutable
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.isAnonymous,
    required this.createdAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'AuthUser(uid: $uid, isAnonymous: $isAnonymous)';
}
