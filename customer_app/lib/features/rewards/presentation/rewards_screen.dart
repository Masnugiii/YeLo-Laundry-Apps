import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final List<RewardHistoryItem> _history = [];
  bool _loading = true;
  String? _error;

  static final _pointsFormat = NumberFormat.decimalPattern('id_ID');
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

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

  String _historyTitle(RewardHistoryItem item) => rewardHistoryLabel(item);

  String _historyPointsLabel(RewardHistoryItem item) {
    final amount = item.point.abs();
    final formatted = _formatPoints(amount);
    final type = item.type.toLowerCase();
    if (type == 'earn' || item.point > 0) {
      return '+ $formatted Point';
    }
    return '- $formatted Point';
  }

  DateTime? _parseDate(String value) => DateTime.tryParse(value);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final history = await ref.read(rewardRepositoryProvider).getHistory();
      if (!mounted) return;
      setState(() {
        _history
          ..clear()
          ..addAll(history.items);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = messageFromError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _load(),
      refreshCustomerYeloPoints(ref),
    ]);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: _poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHistoryRow(RewardHistoryItem item) {
    final earn =
        item.type.toLowerCase() == 'earn' || item.point > 0;
    final date = _parseDate(item.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _historyTitle(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    _dateFormat.format(date.toLocal()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (item.expiredAt != null && item.expiredAt!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Kedaluwarsa: ${item.expiredAt}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Flexible(
            child: Text(
              _historyPointsLabel(item),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: _poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: earn ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return PickupDashboardCard(
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Belum Ada Riwayat',
            style: _poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Aktivitas point kamu akan muncul di sini.',
            style: _poppins(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_loading && _history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
        child: ApiLoadingView(message: 'Memuat riwayat point...'),
      );
    }

    if (_error != null && _history.isEmpty) {
      return ApiErrorView(message: _error!, onRetry: _load);
    }

    if (_history.isEmpty) {
      return _buildEmptyState();
    }

    return PickupDashboardCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s4,
      ),
      child: Column(
        children: [
          for (var i = 0; i < _history.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            _buildHistoryRow(_history[i]),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final membershipLevel = ref.watch(customerMembershipLevelProvider);
    final pointsAsync = ref.watch(customerYeloPointsProvider);
    final points = pointsAsync.asData?.value;
    final loadingPoints = pointsAsync.isLoading && points == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Riwayat Point'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.brandBlue,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  YeloPointBalanceCard(
                    level: membershipLevel,
                    loading: loadingPoints,
                    pointsLabel: points == null
                        ? (pointsAsync.hasError ? '—' : '...')
                        : '${_formatPoints(points)} Point',
                    memberSerialNumber: session.memberSerialNumber,
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  _buildSectionTitle('Riwayat Point'),
                  const SizedBox(height: AppSpacing.s8),
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
