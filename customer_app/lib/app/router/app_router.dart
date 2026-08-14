import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/address/presentation/address_form_screen.dart';
import 'package:yelo_laundry_customer/features/address/presentation/address_list_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/login_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/otp_screen.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/register_screen.dart';
import 'package:yelo_laundry_customer/features/claim_point/presentation/claim_point_screen.dart';
import 'package:yelo_laundry_customer/features/help/presentation/about_screen.dart';
import 'package:yelo_laundry_customer/features/help/presentation/customer_service_chat_screen.dart';
import 'package:yelo_laundry_customer/features/help/presentation/help_payment_screen.dart';
import 'package:yelo_laundry_customer/features/help/presentation/help_screen.dart';
import 'package:yelo_laundry_customer/features/legal/presentation/privacy_policy_screen.dart';
import 'package:yelo_laundry_customer/features/legal/presentation/terms_and_conditions_screen.dart';
import 'package:yelo_laundry_customer/features/home/presentation/home_shell.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/notification_detail_screen.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/notifications_screen.dart';
import 'package:yelo_laundry_customer/features/onboarding/presentation/onboarding_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/delivery_tracking_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/laundry_status_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/order_payment_flow_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/laundry_tracking_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/order_detail_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/order_timeline_screen.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/orders_screen.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/pickup_checkout_flow_screen.dart';
import 'package:yelo_laundry_customer/features/promo/presentation/promo_detail_screen.dart';
import 'package:yelo_laundry_customer/features/promo/presentation/promo_screen.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';
import 'package:yelo_laundry_customer/features/profile/presentation/change_phone_screen.dart';
import 'package:yelo_laundry_customer/features/profile/presentation/edit_profile_screen.dart';
import 'package:yelo_laundry_customer/features/profile/presentation/profile_screen.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/reward_redemptions_screen.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/rewards_screen.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/yelo_rewards_screen.dart';
import 'package:yelo_laundry_customer/features/settings/presentation/settings_screen.dart';
import 'package:yelo_laundry_customer/features/splash/presentation/splash_screen.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/wallet_history_screen.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/wallet_screen.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/wallet_top_up_screen.dart';

/// Stable navigator keys must live outside [appRouterProvider] so they are not
/// recreated when the router is rebuilt (e.g. auth refresh).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final shellHomeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final shellPickupNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellPickup');
final shellOrdersNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellOrders');
final shellProfileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');
final appRouterProvider = Provider<GoRouter>((ref) {
  // Do NOT watch authProvider here — recreating GoRouter resets to
  // initialLocation (/splash) after login. Refresh redirects in-place instead.
  final refresh = _AuthRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;
      final path = state.matchedLocation;

      const publicRoutes = {
        '/splash',
        '/onboarding',
        '/login',
        '/register',
        '/otp',
      };

      // Cold-start restore only — never after OTP/login (completeAuth).
      if (isLoading) {
        return path == '/splash' ? null : '/splash';
      }

      // SplashScreen owns leaving /splash (minimum visual duration on startup).
      if (path == '/splash') return null;

      if (!isAuth && !publicRoutes.contains(path)) return '/login';
      // Login/OTP/register → Dashboard directly (no splash).
      if (isAuth && publicRoutes.contains(path)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
          purpose: state.uri.queryParameters['purpose'] ?? 'login',
          otpRequestId: state.uri.queryParameters['otpRequestId'] ?? '',
          maskedPhone: state.uri.queryParameters['maskedPhone'],
          name: state.uri.queryParameters['name'],
          age: int.tryParse(state.uri.queryParameters['age'] ?? ''),
          occupation: state.uri.queryParameters['occupation'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: shellHomeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellPickupNavigatorKey,
            routes: [
              GoRoute(
                path: '/pickup',
                builder: (_, _) => const PickupCheckoutFlowScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellOrdersNavigatorKey,
            routes: [
              GoRoute(
                path: '/completed-orders',
                builder: (_, _) => const OrdersScreen(
                  initialStatusFilter: 'COMPLETED',
                  title: 'Pesanan Selesai',
                  showStatusFilters: false,
                  useDashboardStyle: true,
                  showBackButton: true,
                  backToDashboard: true,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellProfileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/promo',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PromoScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, state) => PromoDetailScreen(
              promoId: state.pathParameters['id']!,
              initialPromo: state.extra as CustomerPromo?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/addresses',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/addresses/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AddressFormScreen(),
      ),
      GoRoute(
        path: '/addresses/:id/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => AddressFormScreen(
          addressId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/wallet',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const WalletScreen(),
      ),
      GoRoute(
        path: '/wallet/history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const WalletHistoryScreen(),
      ),
      GoRoute(
        path: '/wallet/top-up',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const WalletTopUpScreen(),
      ),
      GoRoute(
        path: '/rewards',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const RewardsScreen(),
      ),
      GoRoute(
        path: '/rewards/redemptions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const RewardRedemptionsScreen(),
      ),
      GoRoute(
        path: '/yelo-rewards',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const YeloRewardsScreen(),
      ),
      GoRoute(
        path: '/claim-point',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ClaimPointScreen(),
      ),
      GoRoute(
        path: '/orders',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const OrdersScreen(
          title: 'Riwayat Pesanan',
          showStatusFilters: false,
          useDashboardStyle: true,
          showBackButton: true,
        ),
      ),
      GoRoute(
        path: '/laundry-status',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const LaundryStatusScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/notifications/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => NotificationDetailScreen(
          notificationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => OrderDetailScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/timeline',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => OrderTimelineScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/tracking',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => LaundryTrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/delivery',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => DeliveryTrackingScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/orders/:id/payment',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => OrderPaymentFlowScreen(
          orderId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/change-phone',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ChangePhoneScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/terms-and-conditions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: '/help',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const HelpScreen(),
        routes: [
          GoRoute(
            path: 'customer-service',
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, _) => const CustomerServiceChatScreen(),
          ),
          GoRoute(
            path: 'payment',
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, _) => const HelpPaymentScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AboutScreen(),
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}
