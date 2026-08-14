import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_order_provider.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/operator_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/operational_summary_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/cashier/cashier_settings_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/dashboard_activity_section.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_header.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_menu_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_operational_summary_row.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/customers_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/incoming_orders_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/role_dashboard_shell.dart';

/// Kasir + Binatu (HP Pribadi) dashboard — identical to operational cashier
/// with an additional personal attendance menu.
class CashierLaundryDashboardScreen extends StatelessWidget {
  const CashierLaundryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      key: const ValueKey('cashier-laundry-dashboard'),
      role: UserRole.cashierLaundry,
      backgroundColor: AppColors.dashboardBackground,
      pages: [
        const _CashierLaundryBerandaPage(
          key: ValueKey('cashier-laundry-dashboard-home'),
        ),
        const CustomersScreen(
          key: ValueKey('cashier-laundry-dashboard-customers'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
        const IncomingOrdersScreen(
          key: ValueKey('cashier-laundry-dashboard-orders'),
          showBackButton: false,
          showBackToDashboard: true,
          title: 'Order',
        ),
        const CashierSettingsScreen(
          key: ValueKey('cashier-laundry-dashboard-settings'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
      ],
    );
  }
}

class _CashierLaundryBerandaPage extends ConsumerWidget {
  const _CashierLaundryBerandaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(binatuOrderProvider);
    final operatorAssistanceCount =
        ref.read(binatuOrderProvider.notifier).operatorAssistanceCompletedCount();
    final badgeState = ref.watch(operatorDashboardBadgeProvider);
    final summaryAsync = ref.watch(operationalSummaryProvider);
    final permissions = ref.watch(staffPermissionsProvider);

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: PosHeader(),
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
                  error: (_, _) => const PosOperationalSummaryRow(
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
                  ],
                ),
                const SizedBox(height: AppSpacing.s32),
                const PosSectionTitle(title: 'Menu Utama'),
                const SizedBox(height: AppSpacing.s16),
                if (permissions.orders)
                  PosMenuCard(
                    title: 'Order Baru',
                    icon: Icons.add_circle_outline,
                    highlight: true,
                    onTap: () => context.push('/new-order'),
                  ),
                if (permissions.unpaidOrders)
                  PosMenuCard(
                    title: 'Belum Bayar',
                    icon: Icons.pending_actions_outlined,
                    onTap: () => context.push('/unpaid-orders'),
                  ),
                if (permissions.customers)
                  PosMenuCard(
                    title: 'Customer',
                    icon: Icons.people_outline,
                    onTap: () => context.push('/customers'),
                  ),
                if (permissions.wallet)
                  PosMenuCard(
                    title: 'Yelo Wallet',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => context.push('/customers'),
                  ),
                if (permissions.pickupDelivery)
                  PosMenuCard(
                    title: 'Pickup & Delivery',
                    icon: Icons.local_shipping_outlined,
                    badgeCount: badgeState.pickupDeliveryUnreadCount,
                    onTap: () {
                      ref
                          .read(operatorDashboardBadgeProvider.notifier)
                          .markPickupDeliveryRead();
                      context.push('/pickup-delivery');
                    },
                  ),
                if (permissions.notification)
                  PosMenuCard(
                    title: 'Notification Center',
                    icon: Icons.notifications_outlined,
                    badgeCount: badgeState.notificationCenterUnreadCount,
                    onTap: () {
                      ref
                          .read(operatorDashboardBadgeProvider.notifier)
                          .markNotificationCenterRead();
                      context.push('/notifications');
                    },
                  ),
                if (permissions.customerService)
                  PosMenuCard(
                    title: 'Customer Service Center',
                    icon: Icons.support_agent_outlined,
                    badgeCount: badgeState.customerServiceUnreadCount,
                    onTap: () {
                      ref
                          .read(operatorDashboardBadgeProvider.notifier)
                          .markCustomerServiceRead();
                      context.push('/customer-service');
                    },
                  ),
                PosMenuCard(
                  title: 'Laci Laundry',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => context.push('/laci-laundry'),
                ),
                if (permissions.attendance)
                  PosMenuCard(
                    title: 'Kehadiran',
                    icon: Icons.fingerprint_outlined,
                    onTap: () => context.push('/attendance/personal'),
                  ),
                const SizedBox(height: AppSpacing.s32),
                const DashboardActivitySection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
