import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../repository/auth_repository.dart';

/// The auth state: AsyncValue<AuthUser?> where null = signed out.
/// States: loading (initial), data(user) = authenticated, data(null) = unauthenticated.
typedef AuthState = AsyncValue<AuthUser?>;

/// Notifier that exposes the current auth state as an AsyncValue stream.
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier(this._repository) : super(const AsyncValue.loading()) {
    _repository.authStateChanges().listen(
      (user) {
        if (user == null) {
          state = const AsyncValue.data(null);
        } else {
          state = AsyncValue.data(user);
        }
      },
      onError: (Object error, StackTrace stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  final AuthRepository _repository;

  /// Triggers anonymous sign-in (used by splash screen).
  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInAnonymously();
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Triggers Google sign-in.
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Signs out.
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

/// Provides the auth state as an AsyncValue<AuthUser?>.
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref.watch(authRepositoryProvider)),
);

/// Convenience extension for checking auth status on AsyncValue<AuthUser?>.
extension AuthStateX on AuthState {
  /// True when the state holds a non-null user.
  bool get isAuthenticated => maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );

  /// True while the initial auth check is in progress.
  bool get isResolving => isLoading || isRefreshing;
}
