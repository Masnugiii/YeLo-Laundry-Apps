import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_order_history.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/features/customer/providers/customer_detail_provider.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_badge.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/point_rewards_card.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_deduction_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_bottom_sheet.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(customerDetailProvider(customerId));

    return profileAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        floatingActionButton: const CustomerFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: _buildAppBar(context),
        body: const ApiLoadingView(),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        floatingActionButton: const CustomerFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: _buildAppBar(context),
        body: ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(customerDetailProvider(customerId)),
        ),
      ),
      data: (profile) => Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        floatingActionButton: const CustomerFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: _buildAppBar(
          context,
          loyaltyClass: loyaltyClassFromPoints(profile.customer.points),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s32,
          ),
          children: [
            _SectionCard(
              title: 'Profile',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DetailRow(
                    label: 'Customer Name',
                    value: profile.customer.name,
                  ),
                  _DetailRow(
                    label: 'Phone Number',
                    value: profile.customer.phone,
                  ),
                  _DetailRow(
                    label: 'Occupation',
                    value: profile.customer.occupation ?? '-',
                  ),
                  _DetailRow(
                    label: 'Home Address',
                    value: profile.customer.address ?? '-',
                    multiline: true,
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _SectionCard(
              title: 'Dompet Yelo',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatRupiah(profile.walletBalance),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Tambah Saldo',
                          backgroundColor: AppColors.primary,
                          textColor: AppColors.onPrimary,
                          onPressed: () => showWalletTopUpBottomSheet(
                            context,
                            currentBalance: profile.walletBalance,
                            customerId: profile.customer.id,
                            customerName: profile.customer.name,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: _ActionButton(
                          label: 'Kurangi Saldo',
                          backgroundColor: AppColors.surface,
                          textColor: AppColors.primary,
                          borderColor: AppColors.primary,
                          onPressed: () => showWalletDeductionBottomSheet(
                            context,
                            currentBalance: profile.walletBalance,
                            customerId: profile.customer.id,
                            customerName: profile.customer.name,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  SizedBox(
                    width: double.infinity,
                    child: _ActionButton(
                      label: 'Riwayat Deposit',
                      backgroundColor: AppColors.accent,
                      textColor: AppColors.primary,
                      onPressed: () => context.push(
                        '/wallet-history?customerId=${profile.customer.id}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            PointRewardsCard(
              points: profile.customer.points,
              onHistoryPressed: () => context.push(
                '/customer/point-history?customerId=${profile.customer.id}',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _SectionCard(
              title: 'Customer Statistics',
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.s12,
                crossAxisSpacing: AppSpacing.s12,
                childAspectRatio: 1.5,
                children: [
                  _StatTile(
                    label: 'Total Order',
                    value: profile.statistics.totalOrders.toString(),
                  ),
                  _StatTile(
                    label: 'Last Order',
                    value: profile.statistics.lastOrder,
                  ),
                  _StatTile(
                    label: 'Total Spending',
                    value: formatRupiah(profile.statistics.totalSpending),
                  ),
                  _StatTile(
                    label: 'Average Order Value',
                    value: formatRupiah(profile.statistics.averageOrderValue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            _SectionCard(
              title: 'Order History',
              child: Column(
                children: [
                  for (var i = 0; i < profile.recentOrders.length; i++)
                    _OrderHistoryTile(
                      order: profile.recentOrders[i],
                      showDivider: i < profile.recentOrders.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    LoyaltyClass? loyaltyClass,
  }) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: BackButton(
        color: AppColors.onPrimary,
        onPressed: () => context.pop(),
      ),
      iconTheme: const IconThemeData(color: AppColors.onPrimary),
      actions: [
        if (loyaltyClass != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s16),
            child: Center(child: LoyaltyBadge(loyaltyClass: loyaltyClass)),
          ),
      ],
      title: Text(
        'Customer',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool showDivider;
  final bool multiline;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const _valueStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(textStyle: _labelStyle),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          value,
          textAlign: TextAlign.start,
          softWrap: multiline,
          style: GoogleFonts.poppins(textStyle: _valueStyle),
        ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.s12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s12),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onPressed,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        side: BorderSide(color: borderColor ?? backgroundColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  const _OrderHistoryTile({required this.order, required this.showDivider});

  final CustomerOrderHistoryItem order;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.queueNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    order.laundryService,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    order.date,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatRupiah(order.orderValue),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  order.status,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s16),
        ],
      ],
    );
  }
}
