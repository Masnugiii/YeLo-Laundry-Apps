import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/data/dummy_dashboard_employee.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/cashier_laundry_driver_permissions.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/manager_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/operational_summary_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/cashier/cashier_settings_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_activity_tile.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_header.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_menu_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_operational_summary_row.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/customers_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/incoming_orders_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/role_dashboard_shell.dart';

/// Kasir + Binatu + Driver (HP Pribadi) dashboard.
class CashierLaundryDriverDashboardScreen extends StatelessWidget {
  const CashierLaundryDriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      key: const ValueKey('cashier-laundry-driver-dashboard'),
      role: UserRole.cashierLaundryDriver,
      backgroundColor: AppColors.dashboardBackground,
      pages: [
        const _CashierLaundryDriverBerandaPage(
          key: ValueKey('cashier-laundry-driver-dashboard-home'),
        ),
        const CustomersScreen(
          key: ValueKey('cashier-laundry-driver-dashboard-customers'),
          showBackButton: false,
        ),
        const IncomingOrdersScreen(
          key: ValueKey('cashier-laundry-driver-dashboard-orders'),
          showBackButton: false,
          title: 'Order',
        ),
        const CashierSettingsScreen(
          key: ValueKey('cashier-laundry-driver-dashboard-settings'),
          showBackButton: false,
        ),
      ],
    );
  }
}

class _CashierLaundryDriverBerandaPage extends ConsumerWidget {
  const _CashierLaundryDriverBerandaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(binatuOrderProvider);
    final operatorAssistanceCount =
        ref.read(binatuOrderProvider.notifier).operatorAssistanceCompletedCount();
    final badgeState = ref.watch(managerDashboardBadgeProvider);
    final summaryAsync = ref.watch(operationalSummaryProvider);

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: PosHeader(
            employeeOverride: dummyManagerDashboardEmployee,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.s32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PosSectionTitle(title: 'Operasional'),
                const SizedBox(height: AppSpacing.s16),
                summaryAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (_, __) => const PosOperationalSummaryRow(
                    items: [
                      PosOperationalSummaryItem(value: '-', label: 'Order Baru'),
                      PosOperationalSummaryItem(
                        value: '-',
                        label: 'Sedang Diproses',
                      ),
                      PosOperationalSummaryItem(
                        value: '-',
                        label: 'Siap Diambil',
                      ),
                    ],
                  ),
                  data: (summary) => PosOperationalSummaryRow(
                    items: [
                      PosOperationalSummaryItem(
                        value: '${summary.newOrders}',
                        label: 'Order Baru',
                      ),
                      PosOperationalSummaryItem(
                        value: '${summary.inProgress}',
                        label: 'Sedang Diproses',
                      ),
                      PosOperationalSummaryItem(
                        value: '${summary.readyForPickup}',
                        label: 'Siap Diambil',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),
                const PosSectionTitle(title: 'Kontribusi Operasional'),
                const SizedBox(height: AppSpacing.s16),
                PosOperationalSummaryRow(
                  items: [
                    PosOperationalSummaryItem(
                      value: '$operatorAssistanceCount',
                      label: 'Operator Assistance',
                    ),
                    PosOperationalSummaryItem(
                      value:
                          '${summaryAsync.value?.laundry['receiving'] ?? 0}',
                      label: 'Total Pickup',
                    ),
                    PosOperationalSummaryItem(
                      value:
                          '${summaryAsync.value?.laundry['readyForPickup'] ?? 0}',
                      label: 'Total Delivery',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s32),
                const PosSectionTitle(title: 'Menu Utama'),
                const SizedBox(height: AppSpacing.s16),
                if (CashierLaundryDriverPermissions.order)
                  PosMenuCard(
                    title: 'Order Baru',
                    icon: Icons.add_circle_outline,
                    highlight: true,
                    onTap: () => context.push('/new-order'),
                  ),
                if (CashierLaundryDriverPermissions.customer)
                  PosMenuCard(
                    title: 'Customer',
                    icon: Icons.people_outline,
                    onTap: () => context.push('/customers'),
                  ),
                if (CashierLaundryDriverPermissions.pickupDelivery)
                  PosMenuCard(
                    title: 'Pickup & Delivery',
                    icon: Icons.local_shipping_outlined,
                    badgeCount: badgeState.pickupDeliveryUnreadCount,
                    onTap: () {
                      ref
                          .read(managerDashboardBadgeProvider.notifier)
                          .markPickupDeliveryRead();
                      context.push('/pickup-delivery');
                    },
                  ),
                if (CashierLaundryDriverPermissions.notificationCenter)
                  PosMenuCard(
                    title: 'Notification Center',
                    icon: Icons.notifications_outlined,
                    badgeCount: badgeState.notificationCenterUnreadCount,
                    onTap: () {
                      ref
                          .read(managerDashboardBadgeProvider.notifier)
                          .markNotificationCenterRead();
                      context.push('/notifications');
                    },
                  ),
                if (CashierLaundryDriverPermissions.yeloWallet)
                  PosMenuCard(
                    title: 'Yelo Wallet',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => context.push('/customers'),
                  ),
                if (CashierLaundryDriverPermissions.attendance)
                  PosMenuCard(
                    title: 'Kehadiran',
                    icon: Icons.fingerprint_outlined,
                    onTap: () => context.push('/attendance/personal'),
                  ),
                if (CashierLaundryDriverPermissions.customerServiceCenter)
                  PosMenuCard(
                    title: 'Customer Service Center',
                    icon: Icons.support_agent_outlined,
                    badgeCount: badgeState.customerServiceUnreadCount,
                    onTap: () {
                      ref
                          .read(managerDashboardBadgeProvider.notifier)
                          .markCustomerServiceRead();
                      context.push('/customer-service');
                    },
                  ),
                if (CashierLaundryDriverPermissions.ironingQueueAssistance)
                  PosMenuCard(
                    title: 'Ironing Queue Assistance',
                    icon: Icons.iron_outlined,
                    onTap: () => context.push('/operator/ironing-assistance'),
                  ),
                const SizedBox(height: AppSpacing.s32),
                const PosSectionTitle(
                  title: 'Aktivitas Hari Ini',
                  actionLabel: 'Lihat Semua',
                ),
                const SizedBox(height: AppSpacing.s16),
                const PosActivityTile(
                  orderNumber: 'Order #1024',
                  customerName: 'Budi Santoso',
                  service: 'Cuci + Setrika',
                  status: 'Diproses',
                  statusColor: AppColors.warning,
                ),
                const PosActivityTile(
                  orderNumber: 'Order #1023',
                  customerName: 'Siti Rahayu',
                  service: 'Cuci Kiloan',
                  status: 'Siap Diambil',
                  statusColor: AppColors.success,
                ),
                const PosActivityTile(
                  orderNumber: 'Order #1022',
                  customerName: 'John Anderson',
                  service: 'Dry Clean',
                  status: 'Pickup',
                  statusColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
