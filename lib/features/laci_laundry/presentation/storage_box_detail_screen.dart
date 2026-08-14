import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/features/laci_laundry/presentation/widgets/laci_feature_app_bar.dart';
import 'package:yelo_laundry_erp/features/laci_laundry/providers/laci_laundry_provider.dart';

class StorageBoxDetailScreen extends ConsumerStatefulWidget {
  const StorageBoxDetailScreen({
    super.key,
    required this.boxCode,
    this.initialBox,
  });

  final String boxCode;
  final Map<String, dynamic>? initialBox;

  @override
  ConsumerState<StorageBoxDetailScreen> createState() => _StorageBoxDetailScreenState();
}

class _StorageBoxDetailScreenState extends ConsumerState<StorageBoxDetailScreen> {
  final _orderIdController = TextEditingController();
  String? _selectedLocker;
  int? _selectedBoxNumber;
  bool _saving = false;

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(laciLaundryBoxProvider(widget.boxCode));
    ref.invalidate(laciLaundryLockersProvider);
    await ref.read(laciLaundryBoxProvider(widget.boxCode).future);
  }

  Future<void> _assignOrder() async {
    final orderId = _orderIdController.text.trim();
    final locker = _selectedLocker;
    final boxNumber = _selectedBoxNumber;

    if (orderId.isEmpty || locker == null || boxNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi order ID, laci, dan kotak')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(laciLaundryRepositoryProvider).assignStorage(
            orderId: orderId,
            lockerCode: locker,
            boxNumber: boxNumber,
          );
      _orderIdController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi penyimpanan berhasil disimpan')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageFromError(error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _moveOrder(String orderId) async {
    final locker = _selectedLocker;
    final boxNumber = _selectedBoxNumber;

    if (locker == null || boxNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih laci dan kotak tujuan')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(laciLaundryRepositoryProvider).moveStorage(
            orderId: orderId,
            lockerCode: locker,
            boxNumber: boxNumber,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order berhasil dipindahkan')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageFromError(error))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<int> _boxNumbersForLocker(String lockerCode) {
    return switch (lockerCode) {
      'A' => List<int>.generate(9, (index) => index + 1),
      'B' || 'C' => List<int>.generate(15, (index) => index + 1),
      _ => <int>[],
    };
  }

  @override
  Widget build(BuildContext context) {
    final boxAsync = ref.watch(laciLaundryBoxProvider(widget.boxCode));
    final canManage = ref.watch(canManageStorageProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: LaciFeatureAppBar(title: 'Laci ${widget.boxCode}'),
      body: boxAsync.when(
        loading: () => const ApiLoadingView(message: 'Memuat detail kotak...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: _refresh,
        ),
        data: (box) {
          final orders = (box['orders'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
          final orderCount = box['orderCount'] as int? ?? orders.length;
          final occupied = orderCount > 0;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.s16),
              children: [
                _InfoCard(
                  title: 'Lokasi',
                  children: [
                    _row('Laci', box['lockerName'] as String? ?? '-'),
                    _row('Kotak', '${box['boxNumber']}'.padLeft(2, '0')),
                    _row('Kode', widget.boxCode),
                    _row('Status', box['statusLabel'] as String? ?? (occupied ? 'TERISI' : 'KOSONG')),
                    _row('Jumlah Order', '$orderCount'),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                _InfoCard(
                  title: occupied ? '$orderCount ORDER' : 'KOSONG',
                  children: orders.isEmpty
                      ? [
                          Text(
                            'Tidak ada order aktif di kotak ini.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ]
                      : orders.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final order = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$index.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  order['customerName'] as String? ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  order['orderNumber'] as String? ?? '-',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                                Text(
                                  order['orderStatus'] as String? ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (canManage)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _saving
                                          ? null
                                          : () => _moveOrder(order['id'] as String),
                                      child: const Text('Pindah'),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
                if (canManage) ...[
                  const SizedBox(height: AppSpacing.s12),
                  _InfoCard(
                    title: 'Assign Order',
                    children: [
                      TextField(
                        controller: _orderIdController,
                        decoration: const InputDecoration(
                          labelText: 'Order ID',
                          hintText: 'UUID order',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLocker,
                        decoration: const InputDecoration(
                          labelText: 'Laci',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('Laci A')),
                          DropdownMenuItem(value: 'B', child: Text('Laci B')),
                          DropdownMenuItem(value: 'C', child: Text('Laci C')),
                        ],
                        onChanged: (value) => setState(() {
                          _selectedLocker = value;
                          _selectedBoxNumber = null;
                        }),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedBoxNumber,
                        decoration: const InputDecoration(
                          labelText: 'Kotak',
                          border: OutlineInputBorder(),
                        ),
                        items: (_selectedLocker == null
                                ? <int>[]
                                : _boxNumbersForLocker(_selectedLocker!))
                            .map(
                              (number) => DropdownMenuItem(
                                value: number,
                                child: Text(number.toString().padLeft(2, '0')),
                              ),
                            )
                            .toList(),
                        onChanged: _selectedLocker == null
                            ? null
                            : (value) => setState(() => _selectedBoxNumber = value),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _assignOrder,
                          child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            ...children,
          ],
        ),
      ),
    );
  }
}
