import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    required this.session,
    this.errorMessage,
  });

  final AuthStatus status;
  final CustomerSession session;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    CustomerSession? session,
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
    Future.microtask(restoreSession);
    return const AuthState(
      status: AuthStatus.initial,
      session: CustomerSession.guest,
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
          session: CustomerSession.guest,
        );
      }
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        session: CustomerSession.guest,
      );
    }
  }

  Future<void> completeAuth(CustomerSession session) async {
    state = AuthState(
      status: AuthStatus.authenticated,
      session: session,
    );
  }

  Future<void> refreshProfile() async {
    if (!state.session.isAuthenticated) return;
    final session = await ref.read(authRepositoryProvider).fetchProfile();
    state = state.copyWith(session: session);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      session: CustomerSession.guest,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      session: CustomerSession.guest,
      errorMessage: message,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final sessionProvider = Provider<CustomerSession>(
  (ref) => ref.watch(authProvider).session,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).status == AuthStatus.authenticated,
);
