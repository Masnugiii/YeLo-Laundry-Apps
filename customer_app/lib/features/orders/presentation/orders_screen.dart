import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/utils/debouncer.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/completed_order_card.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({
    super.key,
    this.initialStatusFilter,
    this.title = 'Pesanan Saya',
    this.showStatusFilters = true,
    this.useDashboardStyle = false,
    this.showBackButton = false,
    this.backToDashboard = false,
  });

  final String? initialStatusFilter;
  final String title;
  final bool showStatusFilters;
  final bool useDashboardStyle;
  final bool showBackButton;
  final bool backToDashboard;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _orderDateFormat = DateFormat('d MMMM yyyy', 'id_ID');

  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  final _scrollController = ScrollController();
  final List<OrderItem> _orders = [];
  int _page = 1;
  bool _loading = false;
  bool _initialLoading = true;
  bool _hasMore = true;
  String? _statusFilter;
  String? _error;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatusFilter;
    _loadInitial();
    _scrollController.addListener(_onScroll);
    if (!widget.useDashboardStyle) {
      _searchController.addListener(() {
        _debouncer.run(() {
          _page = 1;
          _orders.clear();
          _hasMore = true;
          _load();
        });
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loading &&
        _hasMore) {
      _load();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    _page = 1;
    _orders.clear();
    _hasMore = true;
    await _load();
    if (mounted) setState(() => _initialLoading = false);
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(orderRepositoryProvider).getOrders(
            page: _page,
            status: _statusFilter,
            search: widget.useDashboardStyle
                ? null
                : _searchController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        if (_page == 1) {
          _orders
            ..clear()
            ..addAll(result.items);
        } else {
          _orders.addAll(result.items);
        }
        _hasMore = _page < result.meta.totalPages;
        _page++;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    _orders.clear();
    _hasMore = true;
    await _load();
  }

  String _formatOrderDate(String orderDate) {
    final parsed = DateTime.tryParse(orderDate);
    if (parsed == null) return orderDate;
    return _orderDateFormat.format(parsed.toLocal());
  }

  Widget _buildDashboardHeader() {
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
          padding: EdgeInsets.fromLTRB(
            widget.showBackButton ? AppSpacing.s8 : AppSpacing.s16,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Row(
            children: [
              if (widget.showBackButton)
                IconButton(
                  onPressed: () {
                    if (widget.backToDashboard) {
                      context.go('/home');
                    } else {
                      context.pop();
                    }
                  },
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
              else
                const SizedBox.shrink(),
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isOrderHistory = widget.title == 'Riwayat Pesanan';
    final isCompletedOnly = widget.initialStatusFilter == 'COMPLETED';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              isOrderHistory
                  ? 'Belum ada riwayat pesanan.'
                  : isCompletedOnly
                      ? 'Belum Ada Pesanan Selesai'
                      : 'Belum ada pesanan',
              style: _poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isOrderHistory && isCompletedOnly) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Pesanan laundry kamu yang sudah selesai\nakan muncul di sini.',
                style: _poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gagal memuat pesanan',
              style: _poppins(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              _error!,
              style: _poppins(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s16),
            FilledButton(
              onPressed: _loadInitial,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBody() {
    if (_initialLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue),
        ),
      );
    }

    if (_error != null && _orders.isEmpty) {
      return Expanded(child: _buildErrorState());
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.brandBlue,
        child: _orders.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s12,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                children: [_buildEmptyState()],
              )
            : ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s12,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                itemCount: _orders.length + (_hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
                itemBuilder: (context, index) {
                  if (index >= _orders.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.brandBlue,
                        ),
                      ),
                    );
                  }

                  final order = _orders[index];
                  return CompletedOrderCard(
                    order: order,
                    amountText: _currency.format(order.grandTotal),
                    dateText: _formatOrderDate(order.orderDate),
                    onTap: () => context.push('/orders/${order.id}'),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildLegacyBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Cari nomor order...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        if (widget.showStatusFilters)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: _statusFilter == null,
                  onSelected: (_) {
                    setState(() => _statusFilter = null);
                    _refresh();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Aktif'),
                  selected: _statusFilter == 'CREATED',
                  onSelected: (_) {
                    setState(() => _statusFilter = 'CREATED');
                    _refresh();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Selesai'),
                  selected: _statusFilter == 'COMPLETED',
                  onSelected: (_) {
                    setState(() => _statusFilter = 'COMPLETED');
                    _refresh();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Batal'),
                  selected: _statusFilter == 'CANCELLED',
                  onSelected: (_) {
                    setState(() => _statusFilter = 'CANCELLED');
                    _refresh();
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _orders.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _orders.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final order = _orders[index];
                return ListTile(
                  title: Text(order.orderNumber),
                  subtitle: Text('${order.orderStatus} • ${order.paymentStatus}'),
                  trailing: Text(_currency.format(order.grandTotal)),
                  onTap: () => context.push('/orders/${order.id}'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useDashboardStyle) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildDashboardHeader(),
            _buildDashboardBody(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildLegacyBody(),
    );
  }
}
