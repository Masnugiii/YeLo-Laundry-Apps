import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

/// Single startup splash: YeLo blue + [Logo_SplashLoading.png].
///
/// Visible for at least [_minVisible] while still waiting on auth restore.
/// Navigates as soon as both are satisfied: max(0.8s, restoreSession).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const splashLogoAsset = 'assets/images/Logo_SplashLoading.png';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashBackground = AppColors.brandBlue;
  static const _minVisible = Duration(milliseconds: 800);

  /// Moderate width: full logo readable, does not fill the screen.
  static const _logoWidthFactor = 0.55;

  static const _systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: _splashBackground,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: _splashBackground,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  late final DateTime _shownAt;
  bool _navigated = false;
  Timer? _minVisibleTimer;

  @override
  void initState() {
    super.initState();
    _shownAt = DateTime.now();
  }

  @override
  void dispose() {
    _minVisibleTimer?.cancel();
    super.dispose();
  }

  void _leaveSplashIfReady() {
    if (_navigated || !mounted) return;

    final status = ref.read(authProvider).status;
    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      return;
    }

    // Avoid throwing in widget tests without a GoRouter ancestor.
    if (GoRouter.maybeOf(context) == null) return;

    final remaining = _minVisible - DateTime.now().difference(_shownAt);
    if (remaining > Duration.zero) {
      // Auth finished early — hold splash only for the leftover minimum.
      _minVisibleTimer?.cancel();
      _minVisibleTimer = Timer(remaining, _navigateNow);
      return;
    }

    _navigateNow();
  }

  void _navigateNow() {
    if (_navigated || !mounted) return;

    final status = ref.read(authProvider).status;
    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      return;
    }
    if (GoRouter.maybeOf(context) == null) return;

    _navigated = true;
    _minVisibleTimer?.cancel();
    if (status == AuthStatus.authenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch so we rebuild when restoreSession finishes — do not rely on
    // ref.listen alone (it can miss a state that already settled).
    final auth = ref.watch(authProvider);
    final ready = auth.status != AuthStatus.initial &&
        auth.status != AuthStatus.loading;

    if (ready && !_navigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _leaveSplashIfReady());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: _splashBackground,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: _logoWidthFactor,
            child: Image.asset(
              SplashScreen.splashLogoAsset,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}
