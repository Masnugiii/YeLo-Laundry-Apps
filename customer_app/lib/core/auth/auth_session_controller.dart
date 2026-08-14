/// Tracks the active customer authentication generation.
///
/// Bumped on login/logout so stale in-flight API 401 handlers cannot clear
/// tokens from a newer session.
class AuthSessionController {
  int _epoch = 0;

  int get epoch => _epoch;

  int bump([String? reason]) => ++_epoch;
}
