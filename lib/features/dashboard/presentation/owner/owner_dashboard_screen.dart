import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_financial_kpi_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_header.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_menu_card.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_operational_summary_row.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_section_title.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/owner/widgets/pos_uang_masuk_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_summary_provider.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/incoming_orders_screen.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_screen.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/customers_screen.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/role_dashboard_shell.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      key: const ValueKey('owner-dashboard'),
      role: UserRole.owner,
      backgroundColor: AppColors.dashboardBackground,
      pages: [
        const _OwnerBerandaPage(key: ValueKey('owner-dashboard-home')),
        const CustomersScreen(
          key: ValueKey('owner-dashboard-customers'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
        const IncomingOrdersScreen(
          key: ValueKey('owner-dashboard-orders'),
          showBackButton: false,
          showBackToDashboard: true,
          title: 'Order',
        ),
        const SettingsScreen(
          key: ValueKey('owner-dashboard-settings'),
          showBackButton: false,
          showBackToDashboard: true,
        ),
      ],
    );
  }
}

class _OwnerBerandaPage extends ConsumerWidget {
  const _OwnerBerandaPage({super.key});

  String _formatCurrency(num? value) {
    if (value == null) return 'Rp0';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(ownerDashboardSummaryProvider);

    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: PosHeader(),
        ),
        Expanded(
          child: summaryAsync.when(
            loading: () => const ApiLoadingView(),
            error: (error, _) => ApiErrorView(
              message: messageFromError(error),
              onRetry: () => ref.invalidate(ownerDashboardSummaryProvider),
            ),
            data: (summary) {
              final finance = summary['finance'] as Map<String, dynamic>? ?? {};
              final orders = summary['orders'] as Map<String, dynamic>? ?? {};

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(ownerDashboardSummaryProvider);
                  await ref.read(ownerDashboardSummaryProvider.future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PosSectionTitle(title: 'Ringkasan Keuangan'),
                      const SizedBox(height: AppSpacing.s16),
                      PosFinancialKpiCard(
                        title: 'Uang Masuk Hari Ini',
                        value: _formatCurrency(finance['revenueToday']),
                        subtitle:
                            'Total pembayaran yang sudah diterima hari ini.',
                        onTap: () => showUangMasukBottomSheet(context),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      PosFinancialKpiCard(
                        title: 'Nilai Order Hari Ini',
                        value: _formatCurrency(orders['revenueToday']),
                        subtitle:
                            'Total nilai seluruh order hari ini, termasuk yang belum dibayar.',
                        onTap: () => context.push('/orders/today'),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      PosFinancialKpiCard(
                        title: 'Belum Bayar',
                        value: _formatCurrency(finance['outstandingPayment']),
                        subtitle: 'Total order yang masih belum dilunasi.',
                        onTap: () => context.push('/unpaid-orders'),
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      const PosSectionTitle(title: 'Operasional'),
                      const SizedBox(height: AppSpacing.s16),
                      PosOperationalSummaryRow(
                        items: [
                          PosOperationalSummaryItem(
                            value: '${orders['todayOrders'] ?? 0}',
                            label: 'Order Masuk',
                          ),
                          PosOperationalSummaryItem(
                            value: '${summary['laundry']?['inProgress'] ?? 0}',
                            label: 'Sedang Diproses',
                          ),
                          PosOperationalSummaryItem(
                            value:
                                '${summary['pickupDelivery']?['readyForDelivery'] ?? 0}',
                            label: 'Siap Diambil',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s32),
                      const PosSectionTitle(title: 'Menu Utama'),
                      const SizedBox(height: AppSpacing.s16),
                      PosMenuCard(
                        title: 'Order Baru',
                        icon: Icons.add_circle_outline,
                        highlight: true,
                        onTap: () => context.push('/new-order'),
                      ),
                      PosMenuCard(
                        title: 'Customer',
                        icon: Icons.people_outline,
                        onTap: () => context.push('/customers'),
                      ),
                      PosMenuCard(
                        title: 'Pickup & Delivery',
                        icon: Icons.local_shipping_outlined,
                        onTap: () => context.push('/pickup-delivery'),
                      ),
                      PosMenuCard(
                        title: 'Pengeluaran',
                        icon: Icons.account_balance_wallet_outlined,
                        onTap: () => context.push('/expenses'),
                      ),
                      PosMenuCard(
                        title: 'Laporan',
                        icon: Icons.bar_chart_outlined,
                        onTap: () => context.push('/reports'),
                      ),
                      PosMenuCard(
                        title: 'Kehadiran',
                        icon: Icons.fingerprint_outlined,
                        onTap: () => context.push('/attendance'),
                      ),
                      PosMenuCard(
                        title: 'Kinerja Karyawan',
                        icon: Icons.leaderboard_outlined,
                        onTap: () => context.push('/employee-performance'),
                      ),
                      PosMenuCard(
                        title: 'Monitoring Binatu',
                        icon: Icons.iron_outlined,
                        onTap: () => context.push('/monitoring-binatu'),
                      ),
                      PosMenuCard(
                        title: 'Customer Service Center',
                        icon: Icons.support_agent_outlined,
                        onTap: () => context.push('/customer-service'),
                      ),
                      PosMenuCard(
                        title: 'Laci Laundry',
                        icon: Icons.inventory_2_outlined,
                        onTap: () => context.push('/laci-laundry'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
