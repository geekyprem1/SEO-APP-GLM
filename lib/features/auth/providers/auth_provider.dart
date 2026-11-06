import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../repository/auth_repository.dart';

/// The auth state: `AsyncValue<AuthUser?>` where null = signed out.
/// States: loading (initial), data(user) = authenticated, data(null) = unauthenticated.
typedef AuthState = AsyncValue<AuthUser?>;

/// Notifier that exposes the current auth state as an AsyncValue stream.
///
/// Session state is owned exclusively by the repository's auth stream — sign-in
/// / sign-out actions never write it directly (see [AuthActionNotifier]),
/// otherwise the router would bounce to /splash mid-request.
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    _subscription = _repository.authStateChanges().listen(
      (user) => state = AsyncValue.data(user),
      onError: (Object error, StackTrace stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<AuthUser?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Completes once the session reflects a signed-in user, or after [timeout].
  ///
  /// A sign-in action can finish before the auth stream emits the user; waiting
  /// on this avoids acting on a stale, still-signed-out state.
  Future<bool> waitUntilAuthenticated({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (state.isAuthenticated) return true;
    try {
      await stream.firstWhere((state) => state.isAuthenticated).timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Provides the auth state as an `AsyncValue<AuthUser?>`.
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref.watch(authRepositoryProvider)),
);

/// Runs sign-in / sign-up / sign-out actions.
///
/// Progress and errors stay local to the action so the router (which watches
/// [authStateProvider]) only ever reacts to real session changes.
class AuthActionNotifier extends StateNotifier<AsyncValue<void>> {
  AuthActionNotifier(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> signInAnonymously() =>
      run(() => _repository.signInAnonymously());

  Future<void> signInWithGoogle() => run(() => _repository.signInWithGoogle());

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      run(() => _repository.signInWithEmail(email: email, password: password));

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      run(() => _repository.signUpWithEmail(email: email, password: password));

  Future<void> signOut() => run(() => _repository.signOut());

  /// Executes [action], exposing its progress via this state.
  Future<void> run(Future<void> Function() action) async {
    state = const AsyncValue.loading();
    try {
      await action();
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Clears a previously surfaced action error.
  void clearError() {
    if (state.hasError) state = const AsyncValue.data(null);
  }
}

/// Progress/error state of the last sign-in / sign-out action.
final authActionProvider =
    StateNotifierProvider<AuthActionNotifier, AsyncValue<void>>(
  (ref) => AuthActionNotifier(ref.watch(authRepositoryProvider)),
);

/// Convenience extension for checking auth status on `AsyncValue<AuthUser?>`.
extension AuthStateX on AuthState {
  /// True when the state holds a non-null user.
  bool get isAuthenticated => maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

  /// True while the initial auth check is in progress.
  bool get isResolving => isLoading || isRefreshing;
}
