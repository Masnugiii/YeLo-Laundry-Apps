import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/membership/customer_membership_provider.dart';
import 'package:yelo_laundry_customer/core/membership/customer_yelo_points_provider.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_gender.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/dashboard_status_slider.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/membership_card_preview_selector.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/membership_wallet_card.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/membership_badge.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/completed_order_card.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/laundry_active_order_card.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_status.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';

class HomeDashboard extends ConsumerStatefulWidget {
  const HomeDashboard({super.key});

  @override
  ConsumerState<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends ConsumerState<HomeDashboard> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm');
  static final _orderDateFormat = DateFormat('d MMMM yyyy', 'id_ID');
  static final _pointsFormat = NumberFormat.decimalPattern('id_ID');

  static const _terminalStatuses = {'COMPLETED', 'CANCELLED'};

  WalletSummary? _wallet;
  List<WalletTransaction> _transactions = [];
  OrderItem? _activeOrder;
  List<LaundryTrackingStep> _activeOrderSteps = [];
  OrderItem? _pendingPaymentOrder;
  List<OrderItem> _recentOrders = [];
  int _unreadNotifications = 0;
  bool _loading = true;
  bool _balanceVisible = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _isActiveOrder(String status) {
    return !_terminalStatuses.contains(status.toUpperCase());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = ref.read(sessionProvider);
      final walletFuture = ref.read(walletRepositoryProvider).getWallet(session.id);
      final transactionsFuture =
          ref.read(walletRepositoryProvider).getTransactions(session.id, page: 1);
      final unreadFuture = ref.read(notificationRepositoryProvider).getUnreadCount();
      final pointsFuture = refreshCustomerYeloPoints(ref);
      final ordersFuture = ref.read(orderRepositoryProvider).getOrders(page: 1);

      final results = await Future.wait([
        walletFuture,
        transactionsFuture,
        unreadFuture,
        pointsFuture,
        ordersFuture,
      ]);

      final orders = (results[4] as PaginatedOrders).items;
      final pendingPaymentOrders =
          orders.where((o) => isOrderPaymentPending(o.paymentStatus)).toList();
      final activeOrders = orders
          .where(
            (o) =>
                _isActiveOrder(o.orderStatus) &&
                !isOrderPaymentPending(o.paymentStatus),
          )
          .toList();

      OrderItem? featuredOrder;
      List<LaundryTrackingStep> featuredSteps = [];

      if (activeOrders.isNotEmpty) {
        featuredOrder = activeOrders.first;
        try {
          featuredSteps = await ref
              .read(orderRepositoryProvider)
              .getLaundryTracking(featuredOrder.id);
        } catch (_) {
          featuredSteps = [];
        }
      }

      if (!mounted) return;
      setState(() {
        _wallet = results[0] as WalletSummary;
        _transactions = (results[1] as PaginatedResponse<WalletTransaction>).items;
        _unreadNotifications = results[2] as int;
        _pendingPaymentOrder =
            pendingPaymentOrders.isNotEmpty ? pendingPaymentOrders.first : null;
        _activeOrder = featuredOrder;
        _activeOrderSteps = featuredSteps;
        _recentOrders = orders.take(3).toList();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatPoints(int points) => _pointsFormat.format(points);

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
        return Icons.local_laundry_service_outlined;
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

  Widget _buildActivityIcon(WalletTransaction item) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _activityIconBackground(item),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _activityIcon(item),
        size: 18,
        color: AppColors.brandBlue,
      ),
    );
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

  String _activitySubtitle(WalletTransaction item) {
    final income = _isIncome(item);
    final amount = item.amount.abs();
    if (income) {
      return '+ ${_currency.format(amount)}';
    }
    return '- ${_currency.format(amount)}';
  }

  DateTime? _parseDate(String value) {
    return DateTime.tryParse(value);
  }

  String _formatOrderDate(String orderDate) {
    final parsed = _parseDate(orderDate);
    if (parsed == null) return orderDate;
    return _orderDateFormat.format(parsed.toLocal());
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

  String _customerFirstName(CustomerSession session) {
    return session.fullName.trim().split(RegExp(r'\s+')).first;
  }

  String? _greetingHonorific(CustomerGender? gender) {
    return switch (gender) {
      CustomerGender.male => 'Bapak',
      CustomerGender.female => 'Ibu',
      CustomerGender.other || null => null,
    };
  }

  String _greetingPrefix(CustomerSession session) {
    final hasCustomerName = session.fullName.trim().isNotEmpty;
    if (!hasCustomerName) return 'Selamat Datang';

    final honorific = _greetingHonorific(session.gender);
    if (honorific == null) return 'Selamat Datang, ';

    return 'Selamat Datang, $honorific ';
  }

  String _avatarInitial(CustomerSession session) {
    final name = session.fullName.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return 'Y';
  }

  Widget _buildProfileAvatar(CustomerSession session) {
    const avatarRadius = 20.0;
    const profileCircleColor = Color(0xFFF4E900);
    final photoUrl = session.photoUrl?.trim();
    final initial = _avatarInitial(session);
    final membershipLevel = ref.watch(customerMembershipLevelProvider);

    final avatar = photoUrl != null && photoUrl.isNotEmpty
        ? CircleAvatar(
            radius: avatarRadius,
            backgroundColor: profileCircleColor,
            backgroundImage: NetworkImage(photoUrl),
          )
        : CircleAvatar(
            radius: avatarRadius,
            backgroundColor: profileCircleColor,
            child: Text(
              initial,
              style: _poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brandBlue,
              ),
            ),
          );

    return ProfileAvatarWithMembershipBadge(
      level: membershipLevel,
      radius: avatarRadius,
      onTap: () => context.go('/profile'),
      avatar: avatar,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _poppins(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Lihat >',
            style: _poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.brandBlue)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gagal memuat dashboard',
                  style: _poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: _poppins(fontSize: 14, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _load,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.brandBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, session)),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(child: _buildStatusSliderSection()),
            SliverToBoxAdapter(child: _buildLaundrySection()),
            SliverToBoxAdapter(child: _buildActivitySection()),
            SliverToBoxAdapter(child: _buildOrderHistorySection()),
            const SliverPadding(
              padding: EdgeInsets.only(bottom: AppSpacing.s16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CustomerSession session,
  ) {
    final balance = _wallet?.balance ?? session.walletBalance;
    final pointsAsync = ref.watch(customerYeloPointsProvider);
    final yeloPoints = pointsAsync.when(
      data: (value) => value,
      loading: () => null,
      error: (_, _) => null,
    );
    final customerName = _customerFirstName(session);
    final hasCustomerName = session.fullName.trim().isNotEmpty;
    final greetingPrefix = _greetingPrefix(session);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: greetingPrefix,
                            style: _poppins(
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          if (hasCustomerName)
                            TextSpan(
                              text: customerName,
                              style: _poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => context.push('/notifications'),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Badge(
                        isLabelVisible: _unreadNotifications > 0,
                        label: Text('$_unreadNotifications'),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  _buildProfileAvatar(session),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              if (kDebugMode) ...[
                MembershipCardPreviewSelector(
                  selected: ref.watch(customerMembershipLevelProvider),
                  onChanged: (level) => ref
                      .read(membershipDebugPreviewProvider.notifier)
                      .setPreview(level),
                ),
                const SizedBox(height: AppSpacing.s8),
              ],
              MembershipWalletCard(
                level: ref.watch(customerMembershipLevelProvider),
                balanceText: _balanceVisible
                    ? _currency.format(balance)
                    : 'Rp •••••••',
                pointsText: yeloPoints == null
                    ? (pointsAsync.hasError ? '—' : '...')
                    : _formatPoints(yeloPoints),
                balanceVisible: _balanceVisible,
                onToggleBalanceVisibility: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                memberSerialNumber: session.memberSerialNumber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        0,
      ),
      child: PickupDashboardCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s12,
          horizontal: AppSpacing.s8,
        ),
        child: Row(
          children: [
            Expanded(
              child: _QuickActionItem(
                icon: Icons.stars_outlined,
                label: 'YeLo Rewards',
                onTap: () => context.push('/yelo-rewards'),
              ),
            ),
            Expanded(
              child: _QuickActionItem(
                icon: Icons.local_offer_outlined,
                label: 'Promo',
                onTap: () => context.go('/promo'),
              ),
            ),
            Expanded(
              child: _QuickActionItem(
                icon: Icons.local_shipping_outlined,
                label: 'Cek Status Laundry',
                onTap: () => context.go('/laundry-status'),
              ),
            ),
            Expanded(
              child: _QuickActionItem(
                icon: Icons.add_card_outlined,
                label: 'Top Up',
                onTap: () => context.push('/wallet/top-up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSliderSection() {
    final paymentOrder = _pendingPaymentOrder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        0,
      ),
      child: DashboardStatusSlider(
        pendingPaymentOrder: paymentOrder,
        pendingOrder: _activeOrder,
        pendingOrderSteps: _activeOrderSteps,
        amountText: (amount) => _currency.format(amount),
        onPendingPaymentTap: paymentOrder == null
            ? null
            : () async {
                final paid = await context.push<bool>(
                  '/orders/${paymentOrder.id}/payment',
                );
                if (paid == true && mounted) {
                  await _load();
                }
              },
        onPendingOrderTap: () {
          final order = _activeOrder;
          if (order == null) return;
          context.push('/orders/${order.id}/tracking');
        },
      ),
    );
  }

  Widget _buildLaundrySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Laundry Saya',
            onSeeAll: () => context.go('/laundry-status'),
          ),
          const SizedBox(height: AppSpacing.s8),
          if (_activeOrder == null)
            PickupDashboardCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_laundry_service_outlined,
                      size: 36,
                      color: AppColors.textSecondary.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        'Belum ada laundry aktif',
                        style: _poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            LaundryActiveOrderCard(
              key: ValueKey(_activeOrder!.id),
              order: _activeOrder!,
              steps: _activeOrderSteps,
              compact: true,
              onTap: () => context.push('/orders/${_activeOrder!.id}/tracking'),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    final items = _transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        0,
      ),
      child: PickupDashboardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'Aktivitas Terbaru',
              onSeeAll: () => context.go('/wallet/history'),
            ),
            const SizedBox(height: AppSpacing.s8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Belum ada aktivitas',
                        style: _poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items.map(_buildActivityTile),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistorySection() {
    final items = _recentOrders;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Riwayat Pesanan',
            onSeeAll: () => context.push('/order-history'),
          ),
          const SizedBox(height: AppSpacing.s8),
          if (items.isEmpty)
            PickupDashboardCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Belum ada riwayat pesanan.',
                        style: _poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < items.length - 1 ? AppSpacing.s12 : 0,
                ),
                child: CompletedOrderCard(
                  key: ValueKey(order.id),
                  order: order,
                  amountText: _currency.format(order.grandTotal),
                  dateText: _formatOrderDate(order.orderDate),
                  onTap: () => context.push('/orders/${order.id}'),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActivityTile(WalletTransaction item) {
    final income = _isIncome(item);
    final date = _parseDate(item.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityIcon(item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activityTitle(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _activitySubtitle(item),
                  style: _poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: income ? AppColors.success : AppColors.error,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat.format(date.toLocal()),
                    style: _poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const _iconSize = 36.0;
  static const _iconContainerSize = 48.0;

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _iconContainerSize,
                height: _iconContainerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.brandBlue,
                  size: _iconSize,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
