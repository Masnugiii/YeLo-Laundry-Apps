import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/customer/presentation/widgets/customer_fab.dart';
import 'package:yelo_laundry_erp/features/points/models/yelo_rewards_models.dart';
import 'package:yelo_laundry_erp/features/points/providers/yelo_rewards_provider.dart';
import 'package:yelo_laundry_erp/features/points/utils/points_formatter.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class RewardHistoryScreen extends ConsumerWidget {
  const RewardHistoryScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(yeloRewardsSummaryProvider(customerId));

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      floatingActionButton: const CustomerFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Riwayat Reward',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: rewardsAsync.when(
        loading: () => const ApiLoadingView(),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () =>
              ref.invalidate(yeloRewardsSummaryProvider(customerId)),
        ),
        data: (summary) {
          if (summary.redemptions.isEmpty) {
            return Center(
              child: Text(
                'Belum ada riwayat reward',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(yeloRewardsSummaryProvider(customerId));
              await ref.read(yeloRewardsSummaryProvider(customerId).future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              itemCount: summary.redemptions.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                return _RewardHistoryTile(
                  redemption: summary.redemptions[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RewardHistoryTile extends StatelessWidget {
  const _RewardHistoryTile({required this.redemption});

  final RewardRedemptionSummary redemption;

  @override
  Widget build(BuildContext context) {
    final title = redemption.items.isEmpty
        ? 'Reward'
        : redemption.items.map((item) => item.rewardName).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.md(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text(
                _statusLabel(redemption.status),
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
            '${formatPoints(redemption.totalPointsSpent)} Point',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            _formatDate(redemption.createdAt),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status.toUpperCase()) {
      'PENDING' => 'Menunggu diambil',
      'COMPLETED' => 'Siap digunakan',
      'CANCELLED' => 'Dibatalkan',
      _ => status,
    };
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
