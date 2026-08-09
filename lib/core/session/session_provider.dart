import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/app_user_session.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    required this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUserSession session;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUserSession? session,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    if (kDebugMode) {
      // Development builds always start at the login screen so the user can
      // choose an operational mode before authenticating.
      return const AuthState(
        status: AuthStatus.unauthenticated,
        session: AppUserSession.guest,
      );
    }

    Future.microtask(restoreSession);
    return const AuthState(
      status: AuthStatus.initial,
      session: AppUserSession.guest,
    );
  }

  Future<void> restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final session = await ref.read(authRepositoryProvider).restoreSession();
      if (session != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          session: session,
        );
      } else {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          session: AppUserSession.guest,
        );
      }
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        session: AppUserSession.guest,
        errorMessage: error is ApiException ? error.message : null,
      );
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final session = await ref.read(authRepositoryProvider).login(
            phone: phone,
            password: password,
          );
      state = AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        session: AppUserSession.guest,
        errorMessage: error is ApiException
            ? error.message
            : 'Login gagal. Periksa nomor dan password.',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      session: AppUserSession.guest,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final sessionProvider = Provider<AppUserSession>(
  (ref) => ref.watch(authProvider).session,
);

final userRoleProvider = Provider<UserRole>(
  (ref) => ref.watch(sessionProvider).role,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).status == AuthStatus.authenticated,
);
