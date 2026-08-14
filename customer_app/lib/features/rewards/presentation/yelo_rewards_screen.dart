import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/membership/customer_membership_provider.dart';
import 'package:yelo_laundry_customer/core/membership/customer_yelo_points_provider.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/claim_point/presentation/widgets/yelo_point_balance_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/utils/reward_labels.dart';

class YeloRewardsScreen extends ConsumerStatefulWidget {
  const YeloRewardsScreen({super.key});

  @override
  ConsumerState<YeloRewardsScreen> createState() => _YeloRewardsScreenState();
}

class _YeloRewardsScreenState extends ConsumerState<YeloRewardsScreen> {
  static final _pointsFormat = NumberFormat.decimalPattern('id_ID');

  List<RewardCatalogItem> _catalog = const [];
  RewardSummary? _summary;
  bool _loading = true;
  String? _error;
  bool _redeeming = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  String _formatPoints(int points) => _pointsFormat.format(points);

  String _formatIdr(int amount) => _pointsFormat.format(amount);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(rewardRepositoryProvider);
      final results = await Future.wait([
        repo.getSummary(),
        repo.getCatalog(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as RewardSummary;
        _catalog = results[1] as List<RewardCatalogItem>;
      });
      await refreshCustomerYeloPoints(ref);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = messageFromError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onRedeemTap(RewardCatalogItem item) async {
    final currentPoints = _summary?.currentPoints ?? 0;
    if (currentPoints < item.costPoints) {
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _RedeemConfirmSheet(
        item: item,
        currentPoints: currentPoints,
        formatPoints: _formatPoints,
      ),
    );

    if (confirmed != true || !mounted) return;
    await _redeem(item);
  }

  Future<void> _redeem(RewardCatalogItem item) async {
    setState(() => _redeeming = true);
    try {
      final result = await ref.read(rewardRepositoryProvider).redeem(
        items: [
          RedeemRewardItemRequest(catalogItemId: item.id),
        ],
        idempotencyKey: createRedeemIdempotencyKey(),
      );

      if (!mounted) return;
      await refreshCustomerYeloPoints(ref);
      await _load();

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Berhasil Ditukar',
            style: _poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reward: ${item.name}', style: _poppins(fontSize: 14)),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Point digunakan: ${_formatPoints(result.redemption.totalPointsSpent)} Point',
                style: _poppins(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Sisa Point: ${_formatPoints(result.availablePoints)} Point',
                style: _poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                item.pointRewardValueIdr != null
                    ? '1 Point = Rp${_formatIdr(item.pointRewardValueIdr!)} nilai reward (bukan uang tunai).'
                    : 'Nilai reward ditentukan backend (bukan uang tunai).',
                style: _poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapRedeemErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider).session;
    final membershipLevel = ref.watch(customerMembershipLevelProvider);
    final pointsAsync = ref.watch(customerYeloPointsProvider);
    final currentPoints =
        _summary?.currentPoints ?? pointsAsync.asData?.value ?? 0;
    final expiredPoints = _summary?.expiredPoints ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DashboardPageHeader(
            title: 'YeLo Rewards',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: _loading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        ApiLoadingView(message: 'Memuat YeLo Rewards...'),
                      ],
                    )
                  : _error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: ApiErrorView(
                            message: _error!,
                            onRetry: _load,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        AppSpacing.s12,
                        AppSpacing.s16,
                        AppSpacing.s24,
                      ),
                      children: [
                        Text(
                          'Tukarkan point kamu dengan berbagai reward.',
                          style: _poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        SizedBox(
                          height: 168,
                          child: YeloPointBalanceCard(
                            level: membershipLevel,
                            pointsLabel:
                                '${_formatPoints(currentPoints)} Point',
                            loading: pointsAsync.isLoading && _summary == null,
                            memberSerialNumber: session.memberSerialNumber,
                          ),
                        ),
                        if (expiredPoints > 0) ...[
                          const SizedBox(height: AppSpacing.s12),
                          PickupDashboardCard(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Expanded(
                                  child: Text(
                                    '${_formatPoints(expiredPoints)} Point sudah kedaluwarsa dan tidak bisa ditukar.',
                                    style: _poppins(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.s16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Reward Tersedia',
                                style: _poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push('/rewards/redemptions'),
                              child: Text(
                                'Riwayat Reward',
                                style: _poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.push('/rewards'),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Lihat riwayat point',
                              style: _poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        ..._catalog.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.s12,
                            ),
                            child: _RewardCatalogCard(
                              item: item,
                              currentPoints: currentPoints,
                              redeeming: _redeeming,
                              onRedeem: () => _onRedeemTap(item),
                              formatPoints: _formatPoints,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          () {
                            final sample = _catalog
                                .map((item) => item.pointRewardValueIdr)
                                .whereType<int>()
                                .cast<int?>()
                                .firstWhere(
                                  (value) => value != null,
                                  orElse: () => null,
                                );
                            if (sample == null) {
                              return 'Point bukan uang tunai dan tidak dapat dicairkan. '
                                  'Nilai reward ditentukan dari konfigurasi Admin.';
                            }
                            return 'Point bukan uang tunai dan tidak dapat dicairkan. '
                                '1 Point = Rp${_formatIdr(sample)} nilai reward.';
                          }(),
                          style: _poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCatalogCard extends StatelessWidget {
  const _RewardCatalogCard({
    required this.item,
    required this.currentPoints,
    required this.redeeming,
    required this.onRedeem,
    required this.formatPoints,
  });

  final RewardCatalogItem item;
  final int currentPoints;
  final bool redeeming;
  final VoidCallback onRedeem;
  final String Function(int) formatPoints;

  @override
  Widget build(BuildContext context) {
    final needed = pointsNeeded(item.costPoints, currentPoints);
    final canRedeem = needed == 0 && item.isActive && !redeeming;

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.isLaundryKg
                      ? Icons.local_laundry_service_outlined
                      : Icons.card_giftcard_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatPoints(item.costPoints)} Point',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.isLaundryKg) ...[
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        item.serviceType?.isNotEmpty == true
                            ? item.serviceType!
                            : (item.description ?? item.name),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Gratis maksimal ${item.kg ?? 0} KG'
                        '${item.serviceDurationDays != null ? ' · ${item.serviceDurationDays} hari' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Jika berat melebihi kuota gratis, kelebihannya dibayar normal.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else if (item.description != null) ...[
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        item.description!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canRedeem ? onRedeem : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRedeem
                    ? AppColors.accent
                    : AppColors.divider,
                foregroundColor: canRedeem
                    ? AppColors.onAccent
                    : AppColors.textSecondary,
                disabledBackgroundColor: AppColors.divider,
                disabledForegroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                canRedeem
                    ? 'Tukar'
                    : 'Butuh ${formatPoints(needed)} Point lagi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedeemConfirmSheet extends StatelessWidget {
  const _RedeemConfirmSheet({
    required this.item,
    required this.currentPoints,
    required this.formatPoints,
  });

  final RewardCatalogItem item;
  final int currentPoints;
  final String Function(int) formatPoints;

  @override
  Widget build(BuildContext context) {
    final after = currentPoints - item.costPoints;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s16,
        AppSpacing.s20,
        MediaQuery.paddingOf(context).bottom + AppSpacing.s20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            item.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (item.isLaundryKg) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Gratis maksimal ${item.kg ?? 0} KG'
              '${item.serviceDurationDays != null ? ' · ${item.serviceDurationDays} hari' : ''}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          _ConfirmRow(label: 'Harga', value: '${formatPoints(item.costPoints)} Point'),
          _ConfirmRow(label: 'Point kamu', value: '${formatPoints(currentPoints)} Point'),
          _ConfirmRow(
            label: 'Setelah ditukar',
            value: '${formatPoints(after)} Point',
            emphasize: true,
          ),
          const SizedBox(height: AppSpacing.s20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tukar Sekarang',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
