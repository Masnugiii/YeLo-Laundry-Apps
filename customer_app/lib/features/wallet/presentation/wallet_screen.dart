import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/membership/customer_membership_provider.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/membership_wallet_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_customer/features/wallet/presentation/widgets/wallet_transaction_row.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  double _balance = 0;
  bool _walletLoading = true;
  String? _walletError;
  bool _balanceVisible = true;

  final List<WalletTransaction> _transactions = [];
  bool _transactionsLoading = true;
  bool _transactionsLoadingMore = false;
  String? _transactionsError;
  int _page = 1;
  bool _hasMore = true;

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _refresh();
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

  Future<void> _refresh() async {
    setState(() {
      _walletLoading = true;
      _walletError = null;
      _transactionsLoading = true;
      _transactionsError = null;
      _transactions.clear();
      _page = 1;
      _hasMore = true;
    });
    await Future.wait([
      _loadWallet(),
      _loadTransactions(),
    ]);
  }

  Future<void> _loadWallet() async {
    try {
      final customerId = ref.read(sessionProvider).id;
      final wallet = await ref.read(walletRepositoryProvider).getWallet(customerId);
      if (mounted) {
        setState(() {
          _balance = wallet.balance;
          _walletError = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _walletError = messageFromError(error));
    } finally {
      if (mounted) setState(() => _walletLoading = false);
    }
  }

  Future<void> _loadTransactions() async {
    if (_transactionsLoadingMore || (!_hasMore && _transactions.isNotEmpty)) {
      return;
    }

    if (_transactions.isEmpty) {
      setState(() {
        _transactionsLoading = true;
        _transactionsError = null;
      });
    } else {
      setState(() => _transactionsLoadingMore = true);
    }

    try {
      final customerId = ref.read(sessionProvider).id;
      final result = await ref.read(walletRepositoryProvider).getTransactions(
            customerId,
            page: _page,
          );
      if (!mounted) return;
      setState(() {
        _transactions.addAll(result.items);
        _hasMore = _page < result.meta.totalPages;
        _page++;
        _transactionsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _transactionsError = messageFromError(error));
    } finally {
      if (mounted) {
        setState(() {
          _transactionsLoading = false;
          _transactionsLoadingMore = false;
        });
      }
    }
  }

  Widget _buildWalletCard(CustomerSession session, MembershipLevel membershipLevel) {
    if (_walletLoading) {
      return const AspectRatio(
        aspectRatio: 2.15,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue),
        ),
      );
    }

    if (_walletError != null) {
      return ApiErrorView(message: _walletError!, onRetry: _loadWallet);
    }

    return MembershipWalletCard(
      level: membershipLevel,
      showPoint: false,
      balanceText: _balanceVisible
          ? _currency.format(_balance)
          : 'Rp •••••••',
      balanceVisible: _balanceVisible,
      onToggleBalanceVisibility: () => setState(
        () => _balanceVisible = !_balanceVisible,
      ),
      memberSerialNumber: session.memberSerialNumber,
    );
  }

  Widget _buildTopUpButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => context.push('/wallet/top-up'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Top Up',
          style: _poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Text(
      'Riwayat Transaksi',
      style: _poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.brandBlue,
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return PickupDashboardCard(
      child: Text(
        'Belum ada transaksi.',
        style: _poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTransactionsContent() {
    if (_transactionsLoading && _transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
        child: ApiLoadingView(message: 'Memuat riwayat transaksi...'),
      );
    }

    if (_transactionsError != null && _transactions.isEmpty) {
      return ApiErrorView(
        message: _transactionsError!,
        onRetry: () {
          setState(() {
            _transactions.clear();
            _page = 1;
            _hasMore = true;
          });
          _loadTransactions();
        },
      );
    }

    if (_transactions.isEmpty) {
      return _buildEmptyTransactions();
    }

    return PickupDashboardCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s4,
      ),
      child: Column(
        children: [
          for (var i = 0; i < _transactions.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.divider),
            WalletTransactionRow(
              item: _transactions[i],
              currency: _currency,
              dateFormat: _dateFormat,
            ),
          ],
          if (_hasMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: _transactionsLoadingMore
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.s12),
                        child: CircularProgressIndicator(
                          color: AppColors.brandBlue,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _loadTransactions,
                      child: Text(
                        'Muat lebih banyak',
                        style: _poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final membershipLevel = ref.watch(customerMembershipLevelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Wallet'),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.brandBlue,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  _buildWalletCard(session, membershipLevel),
                  const SizedBox(height: AppSpacing.s16),
                  _buildTopUpButton(),
                  const SizedBox(height: AppSpacing.s20),
                  _buildSectionTitle(),
                  const SizedBox(height: AppSpacing.s8),
                  _buildTransactionsContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
