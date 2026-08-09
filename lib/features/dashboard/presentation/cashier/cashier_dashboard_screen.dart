import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/dashboard/data/dummy_dashboard_employee.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/cashier_permissions.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/cashier_dashboard_badge_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/cashier/cashier_settings_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_activity_tile.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_header.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_menu_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_operational_summary_row.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/customers_screen.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/incoming_orders_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/role_dashboard_shell.dart';

class CashierDashboardScreen extends StatelessWidget {
  const CashierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      key: const ValueKey('cashier-dashboard'),
      role: UserRole.cashier,
      backgroundColor: AppColors.dashboardBackground,
      pages: [
        const _CashierBerandaPage(key: ValueKey('cashier-dashboard-home')),
        const CustomersScreen(
          key: ValueKey('cashier-dashboard-customers'),
          showBackButton: false,
        ),
        const IncomingOrdersScreen(
          key: ValueKey('cashier-dashboard-orders'),
          showBackButton: false,
          title: 'Order',
        ),
        const CashierSettingsScreen(
          key: ValueKey('cashier-dashboard-settings'),
          showBackButton: false,
        ),
      ],
    );
  }
}

class _CashierBerandaPage extends ConsumerWidget {
  const _CashierBerandaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeState = ref.watch(cashierDashboardBadgeProvider);

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: PosHeader(
            employeeOverride: dummyCashierDashboardEmployee,
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
                const PosOperationalSummaryRow(
                  items: [
                    PosOperationalSummaryItem(
                      value: '6',
                      label: 'Order Baru',
                    ),
                    PosOperationalSummaryItem(
                      value: '9',
                      label: 'Sedang Diproses',
                    ),
                    PosOperationalSummaryItem(
                      value: '4',
                      label: 'Siap Diambil',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s32),
                const PosSectionTitle(title: 'Menu Utama'),
                const SizedBox(height: AppSpacing.s16),
                if (CashierPermissions.order)
                  PosMenuCard(
                    title: 'Order Baru',
                    icon: Icons.add_circle_outline,
                    highlight: true,
                    onTap: () => context.push('/new-order'),
                  ),
                if (CashierPermissions.unpaidOrders)
                  PosMenuCard(
                    title: 'Belum Dibayar',
                    icon: Icons.pending_actions_outlined,
                    onTap: () => context.push('/unpaid-orders'),
                  ),
                if (CashierPermissions.customer)
                  PosMenuCard(
                    title: 'Customer',
                    icon: Icons.people_outline,
                    onTap: () => context.push('/customers'),
                  ),
                if (CashierPermissions.yeloWallet)
                  PosMenuCard(
                    title: 'Yelo Wallet',
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: () => context.push('/customers'),
                  ),
                if (CashierPermissions.pickupDelivery)
                  PosMenuCard(
                    title: 'Pickup & Delivery',
                    icon: Icons.local_shipping_outlined,
                    badgeCount: badgeState.pickupDeliveryUnreadCount,
                    onTap: () {
                      ref
                          .read(cashierDashboardBadgeProvider.notifier)
                          .markPickupDeliveryRead();
                      context.push('/pickup-delivery');
                    },
                  ),
                if (CashierPermissions.notificationCenter)
                  PosMenuCard(
                    title: 'Notification Center',
                    icon: Icons.notifications_outlined,
                    badgeCount: badgeState.notificationCenterUnreadCount,
                    onTap: () {
                      ref
                          .read(cashierDashboardBadgeProvider.notifier)
                          .markNotificationCenterRead();
                      context.push('/notifications');
                    },
                  ),
                if (CashierPermissions.customerServiceCenter)
                  PosMenuCard(
                    title: 'Customer Service Center',
                    icon: Icons.support_agent_outlined,
                    badgeCount: badgeState.customerServiceUnreadCount,
                    onTap: () {
                      ref
                          .read(cashierDashboardBadgeProvider.notifier)
                          .markCustomerServiceRead();
                      context.push('/customer-service');
                    },
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
