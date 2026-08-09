import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  OrderDetail? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final order = await ref.read(orderRepositoryProvider).getOrder(widget.orderId);
    if (mounted) setState(() {
      _order = order;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final order = _order!;
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(order.orderNumber)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: ${order.orderStatus}', style: Theme.of(context).textTheme.titleMedium),
          Text('Pembayaran: ${order.paymentStatus}'),
          Text('Total: ${currency.format(order.grandTotal)}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/orders/${order.id}/tracking'),
            child: const Text('Lacak Proses Laundry'),
          ),
          OutlinedButton(
            onPressed: () => context.push('/orders/${order.id}/timeline'),
            child: const Text('Lihat Timeline'),
          ),
          if (order.deliveryRequired)
            OutlinedButton(
              onPressed: () => context.push('/orders/${order.id}/delivery'),
              child: const Text('Lacak Pengiriman'),
            ),
          const SizedBox(height: 16),
          Text('Item', style: Theme.of(context).textTheme.titleMedium),
          ...order.items.map(
            (item) => ListTile(
              title: Text(item['serviceName']?.toString() ?? 'Service'),
              subtitle: Text('Qty: ${item['quantity']}'),
              trailing: Text(currency.format((item['subtotal'] as num?) ?? 0)),
            ),
          ),
        ],
      ),
    );
  }
}
