import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/presentation/utils/reward_labels.dart';

class RewardRedemptionsScreen extends ConsumerStatefulWidget {
  const RewardRedemptionsScreen({super.key});

  @override
  ConsumerState<RewardRedemptionsScreen> createState() =>
      _RewardRedemptionsScreenState();
}

class _RewardRedemptionsScreenState
    extends ConsumerState<RewardRedemptionsScreen> {
  final List<RewardRedemption> _items = [];
  bool _loading = true;
  String? _error;
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result =
          await ref.read(rewardRepositoryProvider).getRedemptions();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = messageFromError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DashboardPageHeader(
            title: 'Riwayat Reward',
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
                        ApiLoadingView(),
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
                  : _items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            'Belum ada penukaran reward.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.s12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final date = DateTime.tryParse(item.createdAt);
                        return PickupDashboardCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.primaryRewardName,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                date == null
                                    ? item.createdAt
                                    : _dateFormat.format(date.toLocal()),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              Row(
                                children: [
                                  Text(
                                    '-${item.totalPointsSpent} Point',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    redemptionStatusLabel(item.status),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
