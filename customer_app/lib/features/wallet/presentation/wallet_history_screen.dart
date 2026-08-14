import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

class WalletHistoryScreen extends ConsumerStatefulWidget {
  const WalletHistoryScreen({super.key});

  @override
  ConsumerState<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends ConsumerState<WalletHistoryScreen> {
  final List<WalletTransaction> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

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

  bool _isIncome(WalletTransaction item) {
    if (item.amount > 0) return true;
    const incomeTypes = {
      'top_up',
      'TOPUP',
      'refund',
      'promotion',
      'manual_credit',
    };
    return incomeTypes.contains(item.type.toLowerCase()) ||
        incomeTypes.contains(item.type);
  }

  IconData _activityIcon(WalletTransaction item) {
    switch (item.type.toLowerCase()) {
      case 'top_up':
      case 'topup':
        return Icons.account_balance_wallet_outlined;
      case 'deduction':
      case 'payment':
        return Icons.receipt_long_outlined;
      case 'refund':
        return Icons.replay_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      default:
        return _isIncome(item)
            ? Icons.stars_outlined
            : Icons.payments_outlined;
    }
  }

  Color _activityIconBackground(WalletTransaction item) {
    if (item.type.toLowerCase() == 'promotion') {
      return AppColors.accent.withValues(alpha: 0.25);
    }
    return AppColors.brandBlue.withValues(alpha: 0.08);
  }

  String _activityTitle(WalletTransaction item) {
    switch (item.type.toLowerCase()) {
      case 'top_up':
      case 'topup':
        return 'Top Up Wallet';
      case 'deduction':
      case 'payment':
        return 'Pembayaran laundry';
      case 'refund':
        return 'Pengembalian dana';
      case 'promotion':
        return 'Promo';
      default:
        return item.type.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _amountLabel(WalletTransaction item) {
    final income = _isIncome(item);
    final amount = item.amount.abs();
    if (income) {
      return '+ ${_currency.format(amount)}';
    }
    return '- ${_currency.format(amount)}';
  }

  String? _transactionDetail(WalletTransaction item) {
    if (item.referenceNumber != null && item.referenceNumber!.isNotEmpty) {
      return item.referenceNumber;
    }
    if (item.notes != null && item.notes!.isNotEmpty) {
      return item.notes;
    }
    return null;
  }

  DateTime? _parseDate(String value) => DateTime.tryParse(value);

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
    });
    await _load();
  }

  Future<void> _load() async {
    if (_loadingMore || (!_hasMore && _items.isNotEmpty)) return;
    if (_items.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final customerId = ref.read(sessionProvider).id;
      final result = await ref.read(walletRepositoryProvider).getTransactions(
            customerId,
            page: _page,
          );
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = _page < result.meta.totalPages;
        _page++;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = messageFromError(error));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Widget _buildActivityIcon(WalletTransaction item) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _activityIconBackground(item),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _activityIcon(item),
        size: 18,
        color: AppColors.brandBlue,
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction item) {
    final income = _isIncome(item);
    final date = _parseDate(item.createdAt);
    final detail = _transactionDetail(item);

    return PickupDashboardCard(
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityIcon(item),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activityTitle(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  _amountLabel(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: income ? AppColors.success : AppColors.error,
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
                if (detail != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    detail,
                    maxLines: 2,
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return PickupDashboardCard(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
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
            'Transaksi Wallet kamu akan muncul di sini.',
            style: _poppins(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const ApiLoadingView(message: 'Memuat riwayat transaksi...');
    }

    if (_error != null && _items.isEmpty) {
      return ApiErrorView(message: _error!, onRetry: _refresh);
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [_buildEmptyState()],
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.brandBlue,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.s12),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            if (!_loadingMore) {
              _load();
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
            );
          }
          return _buildTransactionCard(_items[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DashboardPageHeader(
            title: 'Riwayat Wallet',
            showBack: true,
            onBack: () => context.go('/home'),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
