import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/auth/auth_debug_log.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    required this.session,
    this.errorMessage,
    this.isDevPreview = false,
  });

  final AuthStatus status;
  final CustomerSession session;
  final String? errorMessage;
  final bool isDevPreview;

  AuthState copyWith({
    AuthStatus? status,
    CustomerSession? session,
    String? errorMessage,
    bool? isDevPreview,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
      isDevPreview: isDevPreview ?? this.isDevPreview,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  bool _isLoggingOut = false;
  bool _isHandlingUnauthorized = false;
  bool _restoreScheduled = false;

  @override
  AuthState build() {
    DevPreviewGate.resetForProduction();

    if (!_restoreScheduled) {
      _restoreScheduled = true;
      Future.microtask(restoreSession);
    }

    return const AuthState(
      status: AuthStatus.initial,
      session: CustomerSession.guest,
    );
  }

  int get _currentEpoch => ref.read(authSessionControllerProvider).epoch;

  bool _isStaleEpoch(int epoch) => epoch != _currentEpoch;

  void _bumpAuthEpoch(String reason) {
    final epoch = ref.read(authSessionControllerProvider).bump();
    authDebugLog('$reason (epoch=$epoch)');
  }

  Future<void> restoreSession() async {
    if (state.status == AuthStatus.authenticated && !state.isDevPreview) {
      authDebugLog('restoreSession skipped: already authenticated');
      return;
    }

    final epoch = _currentEpoch;
    authDebugLog('restoreSession started');

    if (!_isStaleEpoch(epoch)) {
      state = state.copyWith(status: AuthStatus.loading);
    }

    try {
      final session = await ref.read(authRepositoryProvider).restoreSession();
      if (!ref.mounted || _isStaleEpoch(epoch)) {
        authDebugLog('restoreSession stale, ignored');
        return;
      }

      if (session != null) {
        final hasTokens = await ref.read(secureStorageProvider).hasTokens();
        if (!ref.mounted || _isStaleEpoch(epoch)) {
          authDebugLog('restoreSession stale after token check, ignored');
          return;
        }

        if (!hasTokens) {
          authDebugLog('restoreSession blocked: tokens missing');
          state = const AuthState(
            status: AuthStatus.unauthenticated,
            session: CustomerSession.guest,
          );
          return;
        }

        state = AuthState(
          status: AuthStatus.authenticated,
          session: session,
        );
      } else {
        final hasTokens = await ref.read(secureStorageProvider).hasTokens();
        if (!ref.mounted || _isStaleEpoch(epoch)) return;

        if (hasTokens) {
          final cached =
              await ref.read(preferencesProvider).readCustomerProfile();
          if (!ref.mounted || _isStaleEpoch(epoch)) return;

          if (cached != null) {
            authDebugLog('restoreSession using cached profile with tokens');
            state = AuthState(
              status: AuthStatus.authenticated,
              session: cached,
            );
            return;
          }
        }

        state = const AuthState(
          status: AuthStatus.unauthenticated,
          session: CustomerSession.guest,
        );
      }
    } catch (_) {
      if (!ref.mounted || _isStaleEpoch(epoch)) {
        authDebugLog('restoreSession stale after error, ignored');
        return;
      }

      final hasTokens = await ref.read(secureStorageProvider).hasTokens();
      if (!ref.mounted || _isStaleEpoch(epoch)) return;

      if (hasTokens) {
        final cached = await ref.read(preferencesProvider).readCustomerProfile();
        if (!ref.mounted || _isStaleEpoch(epoch)) return;

        if (cached != null) {
          authDebugLog('restoreSession recovered from cache after error');
          state = AuthState(
            status: AuthStatus.authenticated,
            session: cached,
          );
          return;
        }
      }

      state = const AuthState(
        status: AuthStatus.unauthenticated,
        session: CustomerSession.guest,
      );
    }
  }

  Future<void> completeAuth(CustomerSession session) async {
    final hasTokens = await ref.read(secureStorageProvider).hasTokens();
    if (!hasTokens) {
      authDebugLog('completeAuth blocked: tokens missing');
      setError('Gagal menyimpan sesi login. Silakan coba lagi.');
      return;
    }

    _bumpAuthEpoch('completeAuth');
    DevPreviewGate.deactivate();
    state = AuthState(
      status: AuthStatus.authenticated,
      session: session,
    );
  }

  void enterDevPreview() {
    if (!DevPreviewGate.isAvailable) return;

    _bumpAuthEpoch('enterDevPreview');
    DevPreviewGate.activate();
    state = const AuthState(
      status: AuthStatus.authenticated,
      session: DevPreviewData.session,
      isDevPreview: true,
    );
  }

  Future<void> refreshProfile() async {
    if (!state.session.isAuthenticated || state.isDevPreview) return;
    final session = await ref.read(authRepositoryProvider).fetchProfile();
    state = state.copyWith(session: session);
  }

  /// Clears in-memory auth state without calling the logout API.
  void clearLocalSession() {
    authDebugLog('clearLocalSession');
    if (state.isDevPreview) {
      DevPreviewGate.deactivate();
    }

    state = const AuthState(
      status: AuthStatus.unauthenticated,
      session: CustomerSession.guest,
    );
  }

  Future<void> handleUnauthorized(int requestEpoch) async {
    if (_isHandlingUnauthorized || _isLoggingOut) return;
    if (state.status != AuthStatus.authenticated || state.isDevPreview) return;
    if (requestEpoch != _currentEpoch) {
      authDebugLog(
        'handleUnauthorized stale request ignored (epoch=$requestEpoch current=$_currentEpoch)',
      );
      return;
    }

    _isHandlingUnauthorized = true;
    final epochAtStart = _currentEpoch;
    try {
      if (epochAtStart != _currentEpoch) return;

      await ref.read(secureStorageProvider).clearTokens();
      if (epochAtStart != _currentEpoch) {
        authDebugLog('handleUnauthorized aborted after clearTokens');
        return;
      }

      await ref.read(preferencesProvider).clearCustomerProfile();
      if (epochAtStart != _currentEpoch) return;

      _bumpAuthEpoch('handleUnauthorized');
      clearLocalSession();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;

    if (state.isDevPreview) {
      _bumpAuthEpoch('logout dev preview');
      clearLocalSession();
      return;
    }

    _isLoggingOut = true;
    _bumpAuthEpoch('logout');
    try {
      await ref.read(authRepositoryProvider).logout();
      clearLocalSession();
    } finally {
      _isLoggingOut = false;
    }
  }

  void setError(String message) {
    _bumpAuthEpoch('setError');
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
