import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/error_handler.dart';
import '../../../core/error/failures.dart';
import '../models/auth_user.dart';

/// Abstract auth repository interface.
abstract class AuthRepository {
  /// Stream of the current auth state (null when signed out).
  Stream<AuthUser?> authStateChanges();

  /// Signs in anonymously. Returns the resulting [AuthUser].
  Future<AuthUser> signInAnonymously();

  /// Signs in with Google. Returns the resulting [AuthUser].
  Future<AuthUser> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns the current user, or null.
  AuthUser? get currentUser;
}

/// Firebase implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._firestore, this._errorHandler);

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final ErrorHandler _errorHandler;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_toAuthUser);
  }

  @override
  AuthUser? get currentUser => _toAuthUser(_auth.currentUser);

  @override
  Future<AuthUser> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user!;
      await _ensureUserDoc(user);
      return _toAuthUser(user)!;
    } on fb_auth.FirebaseAuthException catch (e, st) {
      throw _errorHandler.convert(e, st);
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      // GoogleSignIn is wired in the concrete provider; this base impl
      // throws so that platforms without Google Sign-In configured fail loudly.
      throw const FirebaseFailure(
        message: 'Google Sign-In is not configured on this platform.',
        code: 'GOOGLE_SIGN_IN_UNAVAILABLE',
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }

  /// Ensures a `users/{uid}` document exists for the given user.
  Future<void> _ensureUserDoc(fb_auth.User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'isAnonymous': user.isAnonymous,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({'lastSeen': FieldValue.serverTimestamp()});
    }
  }

  AuthUser? _toAuthUser(fb_auth.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Override in main.dart with Firebase instances.');
});
