import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/pending_payment_card.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/completed_order_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  const DeliveryTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<DeliveryTrackingScreen> createState() =>
      _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends ConsumerState<DeliveryTrackingScreen> {
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

  static const _deliverySteps = <String>[
    'Pesanan Diproses',
    'Siap Dikirim',
    'Dalam Pengiriman',
    'Selesai',
  ];

  Map<String, dynamic>? _data;
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
        repository.getDeliveryTracking(widget.orderId),
        repository.getOrder(widget.orderId),
      ]);

      if (!mounted) return;
      setState(() {
        _data = results[0] as Map<String, dynamic>?;
        _order = results[1] as OrderDetail;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _formatDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return _dateFormat.format(parsed.toLocal());
  }

  String _deliveryStatusLabel(String? status) {
    return switch ((status ?? '').toUpperCase()) {
      'WAITING_ASSIGNMENT' => 'Menunggu Penugasan Kurir',
      'ASSIGNED' => 'Kurir Ditugaskan',
      'ACCEPTED' => 'Kurir Menerima Pengiriman',
      'OUT_FOR_DELIVERY' => 'Sedang Dalam Pengiriman',
      'ARRIVED' => 'Kurir Telah Tiba',
      'COMPLETED' => 'Pengiriman Selesai',
      'FAILED' => 'Pengiriman Gagal',
      'CANCELLED' => 'Pengiriman Dibatalkan',
      _ => status?.replaceAll('_', ' ') ?? '-',
    };
  }

  int _activeStepIndex(String? status) {
    return switch ((status ?? '').toUpperCase()) {
      'WAITING_ASSIGNMENT' => 0,
      'ASSIGNED' => 0,
      'ACCEPTED' => 1,
      'OUT_FOR_DELIVERY' => 2,
      'ARRIVED' => 2,
      'COMPLETED' => 3,
      'FAILED' => 2,
      'CANCELLED' => 0,
      _ => 0,
    };
  }

  _DeliveryStepState _stepStateForIndex(int index, String? status) {
    final normalized = (status ?? '').toUpperCase();
    if (normalized == 'COMPLETED') {
      return _DeliveryStepState.completed;
    }
    if (normalized == 'FAILED' || normalized == 'CANCELLED') {
      return index <= _activeStepIndex(status)
          ? _DeliveryStepState.completed
          : _DeliveryStepState.upcoming;
    }

    final activeIndex = _activeStepIndex(status);
    if (index < activeIndex) return _DeliveryStepState.completed;
    if (index == activeIndex) return _DeliveryStepState.current;
    return _DeliveryStepState.upcoming;
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
                      'Lacak Pengiriman',
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
                    maxLines: 1,
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

  Widget _infoRow(String label, String value) {
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderDetail order, Map<String, dynamic> data) {
    final status = data['status']?.toString();
    final statusLabel = _deliveryStatusLabel(status);
    final orderDateLabel = _formatDate(order.orderDate);

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  orderStatusDisplayLabel(order.orderStatus),
                  style: _poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            orderServiceLabel(order),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (orderDateLabel != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              orderDateLabel,
              style: _poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.drive_eta,
                  size: 24,
                  color: AppColors.brandBlue,
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    statusLabel,
                    style: _poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimelineCard(String? status) {
    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pengiriman',
            style: _poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ...List.generate(_deliverySteps.length, (index) {
            final stepState = _stepStateForIndex(index, status);
            final isLast = index == _deliverySteps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 28,
                    child: Column(
                      children: [
                        _DeliveryTimelineNode(state: stepState),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: stepState == _DeliveryStepState.completed
                                  ? AppColors.accent
                                  : AppColors.divider,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : AppSpacing.s20,
                      ),
                      child: Text(
                        _deliverySteps[index],
                        style: _poppins(
                          fontSize: 14,
                          fontWeight: stepState == _DeliveryStepState.current
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: switch (stepState) {
                            _DeliveryStepState.completed =>
                              AppColors.textPrimary,
                            _DeliveryStepState.current => AppColors.brandBlue,
                            _DeliveryStepState.upcoming =>
                              AppColors.textSecondary,
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailCard(Map<String, dynamic> data) {
    final driver = data['driver'] as Map<String, dynamic>?;
    final scheduledLabel = _formatDate(data['scheduledDeliveryAt']?.toString());
    final departedLabel = _formatDate(data['departedAt']?.toString());
    final completedLabel = _formatDate(data['completedAt']?.toString());

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pengiriman',
            style: _poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (driver != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.drive_eta,
                  size: 20,
                  color: AppColors.brandBlue,
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver['fullName']?.toString() ?? '-',
                        style: _poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        driver['phone']?.toString() ?? '-',
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
            const SizedBox(height: AppSpacing.s12),
          ],
          if (scheduledLabel != null)
            _infoRow('Jadwal Pengiriman', scheduledLabel),
          if (departedLabel != null)
            _infoRow('Berangkat', departedLabel),
          if (completedLabel != null)
            _infoRow('Selesai', completedLabel),
          _infoRow('Status', _deliveryStatusLabel(data['status']?.toString())),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drive_eta,
              size: 48,
              color: AppColors.brandBlue.withValues(alpha: 0.35),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Belum ada pengiriman aktif',
              style: _poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Pengiriman untuk pesanan ini belum tersedia atau belum dimulai.',
              style: _poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    final order = _order!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        _buildOrderSummaryCard(order, data),
        const SizedBox(height: AppSpacing.s12),
        _buildStatusTimelineCard(data['status']?.toString()),
        const SizedBox(height: AppSpacing.s12),
        _buildDeliveryDetailCard(data),
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

    if (_error != null) {
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
                        'Gagal memuat lacak pengiriman',
                        style: _poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        _error!,
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Coba lagi',
                          style: _poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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

    if (_data == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(
              subtitle: _order?.orderNumber,
            ),
            Expanded(child: _buildEmptyState()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(subtitle: _order?.orderNumber),
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

enum _DeliveryStepState { completed, current, upcoming }

class _DeliveryTimelineNode extends StatelessWidget {
  const _DeliveryTimelineNode({required this.state});

  final _DeliveryStepState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _DeliveryStepState.completed => Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandBlue, width: 1.5),
          ),
          child: const Icon(
            Icons.check,
            size: 14,
            color: AppColors.brandBlue,
          ),
        ),
      _DeliveryStepState.current => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandBlue, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.45),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      _DeliveryStepState.upcoming => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppColors.divider,
              width: 2,
            ),
          ),
        ),
    };
  }
}
