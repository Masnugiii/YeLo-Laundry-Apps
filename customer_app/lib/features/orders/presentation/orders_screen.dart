import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/utils/debouncer.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();
  final _scrollController = ScrollController();
  final List<OrderItem> _orders = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      _debouncer.run(() {
        _page = 1;
        _orders.clear();
        _hasMore = true;
        _load();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loading &&
        _hasMore) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final result = await ref.read(orderRepositoryProvider).getOrders(
            page: _page,
            status: _statusFilter,
            search: _searchController.text.trim(),
          );
      setState(() {
        _orders.addAll(result.items);
        _hasMore = _page < result.meta.totalPages;
        _page++;
      });
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

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: Column(
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
                    trailing: Text(currency.format(order.grandTotal)),
                    onTap: () => context.push('/orders/${order.id}'),
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
