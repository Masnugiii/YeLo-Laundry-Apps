import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

class PickupRequestScreen extends ConsumerStatefulWidget {
  const PickupRequestScreen({super.key});

  @override
  ConsumerState<PickupRequestScreen> createState() => _PickupRequestScreenState();
}

class _PickupRequestScreenState extends ConsumerState<PickupRequestScreen> {
  List<OrderItem> _orders = [];
  List<CustomerAddress> _addresses = [];
  String? _selectedOrderId;
  String? _selectedAddressId;
  DateTime? _scheduledAt;
  final _notesController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final customerId = ref.read(sessionProvider).id;
      final orders = await ref.read(orderRepositoryProvider).getOrders();
      final addresses = await ref.read(addressRepositoryProvider).list(customerId);
      if (mounted) {
        setState(() {
          _orders = orders.items;
          _addresses = addresses;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedOrderId == null) return;
    setState(() => _submitting = true);
    try {
      await ref.read(pickupRepositoryProvider).createPickupRequest(
            orderId: _selectedOrderId!,
            pickupAddressId: _selectedAddressId,
            scheduledPickupAt: _scheduledAt,
            notes: _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pickup request berhasil dibuat')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Request Pickup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _selectedOrderId,
            decoration: const InputDecoration(labelText: 'Pilih Order'),
            items: _orders
                .map((order) => DropdownMenuItem(value: order.id, child: Text(order.orderNumber)))
                .toList(),
            onChanged: (value) => setState(() => _selectedOrderId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedAddressId,
            decoration: const InputDecoration(labelText: 'Alamat Pickup'),
            items: _addresses
                .map((address) => DropdownMenuItem(
                      value: address.id,
                      child: Text(address.recipientName),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedAddressId = value),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Waktu Pickup'),
            subtitle: Text(_scheduledAt?.toString() ?? 'Pilih waktu'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                initialDate: DateTime.now(),
              );
              if (date == null || !mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time == null) return;
              setState(() {
                _scheduledAt = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            },
          ),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Catatan'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting ? const CircularProgressIndicator() : const Text('Kirim Request'),
          ),
        ],
      ),
    );
  }
}
