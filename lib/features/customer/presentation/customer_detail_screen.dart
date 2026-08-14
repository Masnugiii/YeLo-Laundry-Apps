import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/staff_permissions.dart';
import 'package:yelo_laundry_erp/features/customer/models/customer_order_history.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/features/customer/providers/customer_detail_provider.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/points/models/loyalty_class.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/loyalty_badge.dart';
import 'package:yelo_laundry_erp/features/points/presentation/widgets/yelo_rewards_card.dart';
import 'package:yelo_laundry_erp/features/points/providers/yelo_rewards_provider.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_deduction_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_bottom_sheet.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/yelo_wallet_card.dart';
import 'package:yelo_laundry_erp/features/wallet/providers/wallet_providers.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(customerDetailProvider(customerId));
    final permissions = ref.watch(staffPermissionsProvider);

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
      data: (profile) {
        final rewardsAsync = ref.watch(yeloRewardsSummaryProvider(customerId));
        final loyaltyClass = rewardsAsync.maybeWhen(
          data: (summary) => summary.membershipLevelCode != null
              ? loyaltyClassFromCode(summary.membershipLevelCode)
              : loyaltyClassFromPoints(summary.lifetimePoints ?? summary.currentPoint),
          orElse: () => loyaltyClassFromPoints(profile.customer.points),
        );

        return Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        floatingActionButton: const CustomerFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: _buildAppBar(
          context,
          loyaltyClass: loyaltyClass,
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
              title: 'Informasi Customer',
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
            if (permissions.wallet)
              _CustomerYeloWalletSection(
                customerId: profile.customer.id,
                customerName: profile.customer.name,
                fallbackBalance: profile.walletBalance,
                canTopUp: permissions.walletTopUp,
                canDeduct: permissions.walletDeduct,
              ),
            if (permissions.wallet) const SizedBox(height: AppSpacing.s16),
            _CustomerYeloRewardsSection(customerId: profile.customer.id),
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
      );
      },
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

class _CustomerYeloWalletSection extends ConsumerWidget {
  const _CustomerYeloWalletSection({
    required this.customerId,
    required this.customerName,
    required this.fallbackBalance,
    required this.canTopUp,
    required this.canDeduct,
  });

  final String customerId;
  final String customerName;
  final int fallbackBalance;
  final bool canTopUp;
  final bool canDeduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(customerWalletProvider(customerId));
    final transactionsAsync = ref.watch(walletTransactionsProvider(customerId));

    return walletAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ApiErrorView(
        message: messageFromError(error),
        onRetry: () => ref.invalidate(customerWalletProvider(customerId)),
      ),
      data: (wallet) {
        final currentBalance = wallet.balance.round();
        return YeloWalletCard(
          wallet: wallet.balance == 0 && fallbackBalance > 0
              ? CustomerWalletSummary(
                  walletId: wallet.walletId,
                  customerId: wallet.customerId,
                  balance: fallbackBalance.toDouble(),
                  currency: wallet.currency,
                  isActive: wallet.isActive,
                  totalTopup: wallet.totalTopup,
                  totalSpending: wallet.totalSpending,
                )
              : wallet,
          transactions: transactionsAsync.maybeWhen(
            data: (items) => items,
            orElse: () => const [],
          ),
          transactionsLoading: transactionsAsync.isLoading,
          onHistoryPressed: () => context.push(
            '/wallet-history?customerId=$customerId',
          ),
          onTopUpPressed: canTopUp
              ? () => showWalletTopUpBottomSheet(
                    context,
                    currentBalance: currentBalance,
                    customerId: customerId,
                    customerName: customerName,
                  )
              : null,
          onDeductPressed: canDeduct
              ? () => showWalletDeductionBottomSheet(
                    context,
                    currentBalance: currentBalance,
                    customerId: customerId,
                    customerName: customerName,
                  )
              : null,
        );
      },
    );
  }
}

class _CustomerYeloRewardsSection extends ConsumerStatefulWidget {
  const _CustomerYeloRewardsSection({required this.customerId});

  final String customerId;

  @override
  ConsumerState<_CustomerYeloRewardsSection> createState() =>
      _CustomerYeloRewardsSectionState();
}

class _CustomerYeloRewardsSectionState
    extends ConsumerState<_CustomerYeloRewardsSection> {
  String? _fulfillingId;

  Future<void> _fulfill(RewardRedemptionSummary redemption) async {
    setState(() => _fulfillingId = redemption.id);
    try {
      await ref
          .read(loyaltyRepositoryProvider)
          .fulfillPhysicalRedemption(redemption.id);
      ref.invalidate(yeloRewardsSummaryProvider(widget.customerId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reward fisik ditandai selesai.',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message, style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _fulfillingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewardsAsync =
        ref.watch(yeloRewardsSummaryProvider(widget.customerId));

    return rewardsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => ApiErrorView(
        message: messageFromError(error),
        onRetry: () =>
            ref.invalidate(yeloRewardsSummaryProvider(widget.customerId)),
      ),
      data: (summary) {
        final catalogAsync =
            ref.watch(rewardCatalogProvider(widget.customerId));
        return YeloRewardsCard(
          summary: summary,
          catalog: catalogAsync.maybeWhen(
            data: (items) => items,
            orElse: () => const [],
          ),
          catalogLoading: catalogAsync.isLoading,
          catalogError: catalogAsync.hasError
              ? messageFromError(catalogAsync.error!)
              : null,
          onRetryCatalog: () =>
              ref.invalidate(rewardCatalogProvider(widget.customerId)),
          isFulfillingId: _fulfillingId,
          onPointHistoryPressed: () => context.push(
            '/customer/point-history?customerId=${widget.customerId}',
          ),
          onRewardHistoryPressed: () => context.push(
            '/customer/reward-history?customerId=${widget.customerId}',
          ),
          onFulfillPressed: _fulfill,
        );
      },
    );
  }
}
