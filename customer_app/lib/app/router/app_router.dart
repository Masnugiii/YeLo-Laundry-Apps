import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/address/presentation/address_form_screen.dart';
import 'package:yelo_laundry_customer/features/address/presentation/address_list_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/forgot_password_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/login_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/otp_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/register_screen.dart';
import 'package:yelo_laundry_customer/features/help/presentation/about_screen.dart';
import 'package:yelo_laundry_customer/features/help/presentation/help_screen.dart';
import 'package:yelo_laundry_customer/features/home/presentation/home_shell.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/notification_detail_screen.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/notifications_screen.dart';
import 'package:yelo_laundry_customer/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/delivery_tracking_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/laundry_tracking_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/order_detail_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/order_timeline_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/orders_screen.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/pickup_request_screen.dart';
import 'package:yelo_laundry_customer/features/profile/presentation/edit_profile_screen.dart';
import 'package:yelo_laundry_customer/features/profile/presentation/profile_screen.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/rewards_screen.dart';
import 'package:yelo_laundry_customer/features/settings/presentation/settings_screen.dart';
import 'package:yelo_laundry_customer/features/splash/presentation/splash_screen.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/wallet_history_screen.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/wallet_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;
      final path = state.matchedLocation;

      const publicRoutes = {
        '/splash',
        '/onboarding',
        '/login',
        '/register',
        '/forgot-password',
        '/otp',
      };

      if (isLoading && path != '/splash') return '/splash';
      if (!isAuth && !publicRoutes.contains(path)) return '/login';
      if (isAuth && publicRoutes.contains(path) && path != '/splash') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
          purpose: state.uri.queryParameters['purpose'] ?? 'login',
          otpRequestId: state.uri.queryParameters['otpRequestId'] ?? '',
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomeDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (_, __) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: '/addresses', builder: (_, __) => const AddressListScreen()),
      GoRoute(path: '/addresses/add', builder: (_, __) => const AddressFormScreen()),
      GoRoute(
        path: '/addresses/:id/edit',
        builder: (_, state) => AddressFormScreen(
          addressId: state.pathParameters['id'],
        ),
      ),
      GoRoute(path: '/wallet', builder: (_, __) => const WalletScreen()),
      GoRoute(
        path: '/wallet/history',
        builder: (_, __) => const WalletHistoryScreen(),
      ),
      GoRoute(path: '/rewards', builder: (_, __) => const RewardsScreen()),
      GoRoute(
        path: '/notifications/:id',
        builder: (_, state) => NotificationDetailScreen(
          notificationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (_, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/timeline',
        builder: (_, state) => OrderTimelineScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        builder: (_, state) => LaundryTrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/delivery',
        builder: (_, state) => DeliveryTrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(path: '/pickup', builder: (_, __) => const PickupRequestScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
