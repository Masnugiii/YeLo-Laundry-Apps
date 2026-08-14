import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';
import 'package:yelo_laundry_erp/features/points/utils/points_formatter.dart';

class YeloRewardsCard extends StatelessWidget {
  const YeloRewardsCard({
    super.key,
    required this.summary,
    required this.catalog,
    required this.onPointHistoryPressed,
    required this.onRewardHistoryPressed,
    this.onFulfillPressed,
    this.isFulfillingId,
    this.catalogLoading = false,
    this.catalogError,
    this.onRetryCatalog,
  });

  final YeloRewardsSummary summary;
  final List<RewardCatalogItem> catalog;
  final VoidCallback onPointHistoryPressed;
  final VoidCallback onRewardHistoryPressed;
  final Future<void> Function(RewardRedemptionSummary redemption)?
      onFulfillPressed;
  final String? isFulfillingId;
  final bool catalogLoading;
  final String? catalogError;
  final VoidCallback? onRetryCatalog;

  @override
  Widget build(BuildContext context) {
    final cksItems = summary.cksCustomerEntitlements;
    final pendingPhysical = summary.redemptions
        .where((item) => item.isPhysicalPending)
        .toList();

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
            'YeLo Rewards',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Tukarkan point customer dengan berbagai reward.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Current Point',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            '${formatPoints(summary.currentPoint)} Point',
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
                child: _StatChip(label: 'Earned', value: summary.earned),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _StatChip(label: 'Redeemed', value: summary.redeemed),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: _StatChip(label: 'Expired', value: summary.expired),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _StatChip(label: 'Clawback', value: summary.clawback),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Reward Tersedia',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (catalogLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (catalogError != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catalogError!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
                if (onRetryCatalog != null)
                  TextButton(
                    onPressed: onRetryCatalog,
                    child: Text(
                      'Coba lagi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            )
          else if (catalog.isEmpty)
            Text(
              'Belum ada reward aktif di catalog.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else
            for (final item in catalog)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                child: _RewardCatalogCard(
                  item: item,
                  currentPoints: summary.currentPoint,
                ),
              ),
          const SizedBox(height: AppSpacing.s8),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s12),
          _HistoryRow(
            title: 'Riwayat Point',
            actionLabel: 'Lihat Riwayat',
            onPressed: onPointHistoryPressed,
          ),
          const SizedBox(height: AppSpacing.s8),
          _HistoryRow(
            title: 'Riwayat Reward',
            actionLabel: 'Lihat Riwayat',
            onPressed: onRewardHistoryPressed,
          ),
          if (pendingPhysical.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Reward Fisik Pending',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            for (final redemption in pendingPhysical)
              _RedemptionTile(
                title: redemption.items.isEmpty
                    ? 'Reward'
                    : redemption.items
                        .map((item) => item.rewardName)
                        .join(', '),
                subtitle: '${formatPoints(redemption.totalPointsSpent)} Point',
                trailing: _statusLabel(redemption.status),
                meta: _formatDate(redemption.createdAt),
                actionLabel: 'Fulfill',
                actionLoading: isFulfillingId == redemption.id,
                onAction: onFulfillPressed == null
                    ? null
                    : () => onFulfillPressed!(redemption),
              ),
          ],
          const SizedBox(height: AppSpacing.s12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'CKS Customer',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          if (cksItems.isEmpty)
            Text(
              'Customer belum memiliki CKS.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else
            for (final entitlement in cksItems)
              _CksEntitlementTile(entitlement: entitlement),
          if (_pointValueFootnote(catalog) != null) ...[
            const SizedBox(height: AppSpacing.s16),
            Text(
              _pointValueFootnote(catalog)!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String? _pointValueFootnote(List<RewardCatalogItem> catalog) {
    final sample = catalog
        .map((item) => item.pointRewardValueIdr)
        .whereType<int>()
        .cast<int?>()
        .firstWhere((value) => value != null, orElse: () => null);
    if (sample == null) {
      return 'Point bukan uang tunai dan tidak dapat dicairkan. '
          'Nilai reward ditentukan dari konfigurasi Admin.';
    }
    return 'Point bukan uang tunai dan tidak dapat dicairkan. '
        '1 Point = Rp${formatPoints(sample)} nilai reward.';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _statusLabel(String status) {
    return switch (status.toUpperCase()) {
      'AVAILABLE' => 'Available',
      'PARTIALLY_USED' => 'Partially Used',
      'USED' => 'Used',
      'EXPIRED' => 'Expired',
      'CANCELLED' => 'Cancelled',
      'PENDING' => 'Pending',
      'COMPLETED' => 'Completed',
      _ => status,
    };
  }
}

class _RewardCatalogCard extends StatelessWidget {
  const _RewardCatalogCard({
    required this.item,
    required this.currentPoints,
  });

  final RewardCatalogItem item;
  final int currentPoints;

  @override
  Widget build(BuildContext context) {
    final needed = pointsNeeded(item.costPoints, currentPoints);
    final canRedeem = needed == 0 && item.isActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
                  if (item.entitlementKg != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${item.entitlementKg} KG',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (item.durationDays != null)
                    Text(
                      'Berlaku ${item.durationDays} hari',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: canRedeem
                        ? AppColors.accent.withValues(alpha: 0.35)
                        : AppColors.dashboardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    canRedeem
                        ? 'Point cukup'
                        : 'Butuh ${formatPoints(needed)} Point lagi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: canRedeem
                          ? AppColors.onAccent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionLabel,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CksEntitlementTile extends StatelessWidget {
  const _CksEntitlementTile({required this.entitlement});

  final CksEntitlement entitlement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.dashboardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entitlement.rewardName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  YeloRewardsCard._statusLabel(entitlement.entitlementStatus),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Remaining ${_formatKg(entitlement.remainingKg)} / ${_formatKg(entitlement.entitlementKg)} KG',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              entitlement.expiresAt == null
                  ? '${entitlement.pointsSpent} Point'
                  : 'Expiration ${YeloRewardsCard._formatDate(entitlement.expiresAt!)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatKg(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: AppColors.dashboardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatPoints(value),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RedemptionTile extends StatelessWidget {
  const _RedemptionTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.meta,
    this.actionLabel,
    this.onAction,
    this.actionLoading = false,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final String meta;
  final String? actionLabel;
  final Future<void> Function()? onAction;
  final bool actionLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                trailing,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            meta,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: actionLoading ? null : () => onAction!(),
                child: actionLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
