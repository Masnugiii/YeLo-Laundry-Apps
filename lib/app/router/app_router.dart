import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/role/role_permission.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/binatu_attendance_screen.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/employee_attendance_screen.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/login_mode_selection_screen.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/login_screen.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/otp_screen.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/register_screen.dart';
import 'package:yelo_laundry_erp/features/auth/presentation/signup_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/binatu/binatu_dashboard_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/coming_soon_dashboard_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/cashier/cashier_dashboard_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/cashier/cashier_laundry_driver_dashboard_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/cashier/cashier_laundry_dashboard_screen.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/models/binatu_monitoring_models.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/binatu_monitoring_employee_detail_screen.dart';
import 'package:yelo_laundry_erp/features/binatu_monitoring/presentation/binatu_monitoring_screen.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/binatu_order_detail_screen.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/operator_ironing_assistance_screen.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/notification_center_screen.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/cashier_receipt_printer_settings_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/owner_dashboard_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/role_check_screen.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/add_customer_screen.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/customer_detail_screen.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/customers_screen.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_detail_screen.dart';
import 'package:yelo_laundry_erp/features/employee_master/presentation/employee_master_screen.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/conversation_detail_screen.dart';
import 'package:yelo_laundry_erp/features/customer_service/presentation/customer_service_screen.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/employee_performance_detail_screen.dart';
import 'package:yelo_laundry_erp/features/employee_performance/presentation/employee_performance_screen.dart';
import 'package:yelo_laundry_erp/features/expenses/presentation/expenses_screen.dart';
import 'package:yelo_laundry_erp/features/new_order/presentation/new_order_screen.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_payment.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/cash_payment_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/order_payment_review_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/qris_payment_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/transfer_payment_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/payment/wallet_payment_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/order_payment_success_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/today_orders_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/unpaid_orders_screen.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/presentation/pickup_delivery_screen.dart';
import 'package:yelo_laundry_erp/features/points/presentation/point_history_screen.dart';
import 'package:yelo_laundry_erp/features/reports/presentation/reports_screen.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/laundry_receipt_screen.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/order_number_settings_screen.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/laundry_profile_screen.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/receipt_customization_screen.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_screen.dart';
import 'package:yelo_laundry_erp/features/splash/presentation/splash_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_deduction_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_payment_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_history_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_deduction_processing_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_deduction_receipt_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_deduction_review_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_payment_success_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_top_up_qris_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_top_up_review_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_receipt.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_top_up_receipt_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_top_up_success_screen.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/wallet_top_up_transfer_screen.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this._ref) {
    _ref.listen(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.uri.path;
      final isAuthRoute = path == '/login' ||
          path == '/signup' ||
          path == '/otp' ||
          path == '/register' ||
          path == '/login-mode-selection';

      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return path == '/' ? null : '/';
      }

      if (authState.status != AuthStatus.authenticated) {
        return isAuthRoute || path == '/' ? null : '/login';
      }

      if (isAuthRoute || path == '/') {
        return '/role-check';
      }

      final role = authState.session.role;
      return RolePermissions.redirectForRole(role, path);
    },
    routes: [
    GoRoute(
      path: '/wallet-top-up/qris',
      builder: (context, state) {
        final confirmation = state.extra as WalletTopUpConfirmation;
        return WalletTopUpQrisScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-top-up/transfer',
      builder: (context, state) {
        final confirmation = state.extra as WalletTopUpConfirmation;
        return WalletTopUpTransferScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-top-up/review',
      builder: (context, state) {
        final confirmation = state.extra as WalletTopUpConfirmation;
        return WalletTopUpReviewScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-top-up/receipt',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is WalletTopUpReceipt) {
          return WalletTopUpReceiptScreen(receipt: extra);
        }
        return WalletTopUpReceiptScreen(
          confirmation: extra as WalletTopUpConfirmation?,
        );
      },
    ),
    GoRoute(
      path: '/wallet-top-up-success',
      builder: (context, state) {
        final confirmation = state.extra as WalletTopUpConfirmation;
        return WalletTopUpSuccessScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-deduction/receipt',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is WalletDeductionReceipt) {
          return WalletDeductionReceiptScreen(receipt: extra);
        }
        return WalletDeductionReceiptScreen(
          confirmation: extra as WalletPaymentConfirmation?,
        );
      },
    ),
    GoRoute(
      path: '/wallet-deduction/review',
      builder: (context, state) {
        final confirmation = state.extra as WalletPaymentConfirmation;
        return WalletDeductionReviewScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-deduction/processing',
      builder: (context, state) {
        final confirmation = state.extra as WalletPaymentConfirmation;
        return WalletDeductionProcessingScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-payment-success',
      builder: (context, state) {
        final confirmation = state.extra as WalletPaymentConfirmation;
        return WalletPaymentSuccessScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/order-payment/review',
      builder: (context, state) {
        final session = state.extra as OrderPaymentSession;
        return OrderPaymentReviewScreen(session: session);
      },
    ),
    GoRoute(
      path: '/order-payment/cash',
      builder: (context, state) {
        final session = state.extra as OrderPaymentSession;
        return CashPaymentScreen(session: session);
      },
    ),
    GoRoute(
      path: '/order-payment/qris',
      builder: (context, state) {
        final session = state.extra as OrderPaymentSession;
        return QrisPaymentScreen(session: session);
      },
    ),
    GoRoute(
      path: '/order-payment/transfer',
      builder: (context, state) {
        final session = state.extra as OrderPaymentSession;
        return TransferPaymentScreen(session: session);
      },
    ),
    GoRoute(
      path: '/order-payment/wallet',
      builder: (context, state) {
        final session = state.extra as OrderPaymentSession;
        return WalletPaymentScreen(session: session);
      },
    ),
    GoRoute(
      path: '/order-payment-success',
      builder: (context, state) {
        final confirmation = state.extra as OrderPaymentConfirmation;
        return OrderPaymentSuccessScreen(confirmation: confirmation);
      },
    ),
    GoRoute(
      path: '/wallet-history',
      builder: (context, state) {
        final customerId = state.uri.queryParameters['customerId'] ?? '';
        return WalletHistoryScreen(customerId: customerId);
      },
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login-mode-selection',
      builder: (context, state) => const LoginModeSelectionScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        final isLoginFlow = state.uri.queryParameters['flow'] == 'login';

        return OtpScreen(
          phoneNumber: phone,
          isLoginFlow: isLoginFlow,
        );
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/role-check',
      builder: (context, state) => const RoleCheckScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      redirect: (context, state) => ref.read(sessionProvider).role.dashboardRoute,
    ),
    GoRoute(
      path: '/dashboard-owner',
      builder: (context, state) => const OwnerDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard-cashier',
      builder: (context, state) => const CashierDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard-cashier-laundry',
      builder: (context, state) => const CashierLaundryDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard-cashier-laundry-driver',
      builder: (context, state) => const CashierLaundryDriverDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard-laundry',
      builder: (context, state) => const BinatuDashboardScreen(),
    ),
    GoRoute(
      path: '/dashboard-binatu',
      redirect: (context, state) => '/dashboard-laundry',
    ),
    GoRoute(
      path: '/orders/today',
      builder: (context, state) => const TodayOrdersScreen(),
    ),
    GoRoute(
      path: '/unpaid-orders',
      builder: (context, state) => const UnpaidOrdersScreen(),
    ),
    GoRoute(
      path: '/new-order',
      builder: (context, state) => const NewOrderScreen(),
    ),
    GoRoute(
      path: '/customer/new',
      builder: (context, state) => const AddCustomerScreen(),
    ),
    GoRoute(
      path: '/customer/point-history',
      builder: (context, state) {
        final customerId = state.uri.queryParameters['customerId'] ?? '';
        return PointHistoryScreen(customerId: customerId);
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/employee-master',
      builder: (context, state) => const EmployeeMasterScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return EmployeeDetailScreen(employeeId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/monitoring-binatu',
      builder: (context, state) => const BinatuMonitoringScreen(),
      routes: [
        GoRoute(
          path: ':employeeId',
          builder: (context, state) {
            final employeeId = state.pathParameters['employeeId']!;
            final filter = BinatuMonitoringDateFilterX.fromQuery(
              state.uri.queryParameters['filter'],
            );
            final dateParam = state.uri.queryParameters['date'];
            final initialDate = dateParam == null
                ? null
                : DateTime.tryParse(dateParam);

            return BinatuMonitoringEmployeeDetailScreen(
              employeeId: employeeId,
              initialFilter: filter,
              initialDate: initialDate,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/employee-performance',
      builder: (context, state) => const EmployeePerformanceScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return EmployeePerformanceDetailScreen(employeeId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/customer-service',
      builder: (context, state) => const CustomerServiceScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ConversationDetailScreen(conversationId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/laundry-receipt',
      builder: (context, state) {
        final receipt = state.extra;
        return LaundryReceiptScreen(
          receipt: receipt is LaundryReceipt ? receipt : null,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/order-number',
      builder: (context, state) {
        final readOnly = state.uri.queryParameters['readOnly'] == 'true';
        return OrderNumberSettingsScreen(readOnly: readOnly);
      },
    ),
    GoRoute(
      path: '/settings/cashier/receipt-printer',
      builder: (context, state) => const CashierReceiptPrinterSettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: '/operator/ironing-assistance',
      builder: (context, state) => const OperatorIroningAssistanceScreen(),
    ),
    GoRoute(
      path: '/binatu/orders/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BinatuOrderDetailScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/settings/laundry-profile',
      builder: (context, state) => const LaundryProfileScreen(),
    ),
    GoRoute(
      path: '/settings/receipt-customization',
      builder: (context, state) => const ReceiptCustomizationScreen(),
    ),
    GoRoute(
      path: '/attendance',
      builder: (context, state) => const EmployeeAttendanceScreen(),
      routes: [
        GoRoute(
          path: 'personal',
          builder: (context, state) => const BinatuAttendanceScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpensesScreen(),
    ),
    GoRoute(
      path: '/pickup-delivery',
      builder: (context, state) => const PickupDeliveryScreen(),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CustomerDetailScreen(customerId: id);
          },
        ),
      ],
    ),
  ],
  );
});
