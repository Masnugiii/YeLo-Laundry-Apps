import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/laundry_progress_timeline.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';



class LaundryTrackingScreen extends ConsumerStatefulWidget {
  const LaundryTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<LaundryTrackingScreen> createState() =>
      _LaundryTrackingScreenState();
}

class _LaundryTrackingScreenState extends ConsumerState<LaundryTrackingScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm');

  List<LaundryTrackingStep> _steps = [];
  OrderDetail? _order;
  bool _loading = true;
  String? _error;

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
      final repository = ref.read(orderRepositoryProvider);
      final results = await Future.wait([
        repository.getLaundryTracking(widget.orderId),
        repository.getOrder(widget.orderId),
      ]);

      if (!mounted) return;
      setState(() {
        _steps = results[0] as List<LaundryTrackingStep>;
        _order = results[1] as OrderDetail;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _phaseLabel(int index) {
    return switch (index) {
      0 => 'Diterima',
      1 => 'Sedang Diproses',
      2 => 'Sedang Dicuci',
      3 => 'Sedang Disetrika',
      4 => 'Siap Diambil',
      5 => 'Selesai',
      _ => 'Dalam Proses',
    };
  }

  String _phaseDescription(int index) {
    return switch (index) {
      0 => 'Pesanan kamu telah diterima.',
      1 => 'Pesanan kamu sedang diproses.',
      2 => 'Pesanan kamu sedang dalam proses pencucian.',
      3 => 'Pesanan kamu sedang disetrika.',
      4 => 'Pesanan kamu siap diambil.',
      5 => 'Pesanan kamu telah selesai.',
      _ => 'Pesanan kamu sedang diproses.',
    };
  }

  String? _formatDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return _dateFormat.format(parsed.toLocal());
  }

  String _serviceSummary(OrderDetail order) {
    if (order.items.isEmpty) return '-';
    return order.items
        .map((item) {
          final name =
              item['serviceName']?.toString() ?? item['name']?.toString() ?? 'Jasa';
          final qty = item['quantity'];
          final unit = item['unit']?.toString();
          if (qty == null) return name;
          return unit == null ? '$name ($qty)' : '$name ($qty $unit)';
        })
        .join(', ');
  }

  String? _perfumeFromOrder(OrderDetail order) {
    for (final item in order.items) {
      final perfume = item['perfumeName'] ?? item['perfume'];
      if (perfume != null && perfume.toString().trim().isNotEmpty) {
        return perfume.toString();
      }
    }
    final notes = order.notes?.trim();
    if (notes != null && notes.toLowerCase().contains('parfum')) {
      return notes;
    }
    return null;
  }

  Widget _buildHeader({String? subtitle}) {
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
            AppSpacing.s8,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Lacak Laundry',
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
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.s4),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s8),
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: _poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: _poppins(
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? AppColors.brandBlue : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final order = _order!;
    final uiState = resolveLaundryTimelineUiState(_steps);
    final phaseLabel = _phaseLabel(uiState.currentIndex);
    final phaseDescription = _phaseDescription(uiState.currentIndex);
    final perfume = _perfumeFromOrder(order);
    final orderDateLabel = _formatDate(order.orderDate);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Status Laundry',
                      style: _poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (uiState.isSiapDiambilPhase)
                    Text(
                      'Siap Diambil',
                      textAlign: TextAlign.right,
                      style: _poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandBlue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phaseLabel,
                          style: _poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandBlue,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          phaseDescription,
                          style: _poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_steps.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s16),
                LaundryProgressTimeline(
                  key: ValueKey('tracking-timeline-${widget.orderId}'),
                  steps: _steps,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Pesanan',
                style: _poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              _infoRow('Nomor Order', order.orderNumber),
              _infoRow('Jasa Laundry', _serviceSummary(order)),
              if (perfume != null) _infoRow('Parfum', perfume),
              if (orderDateLabel != null)
                _infoRow('Tanggal Pesanan', orderDateLabel),
              _infoRow(
                'Antar Jemput',
                order.pickupRequired || order.deliveryRequired ? 'Ya' : 'Tidak',
              ),
              _infoRow('Pembayaran', order.paymentStatus),
              _infoRow(
                'Total Pembayaran',
                _currency.format(order.grandTotal),
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(subtitle: 'Memuat data...'),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null || _order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gagal memuat lacak laundry',
                        style: _poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        _error ?? 'Data pesanan tidak tersedia.',
                        style: _poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s16),
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
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(subtitle: _order!.orderNumber),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppColors.brandBlue,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}
