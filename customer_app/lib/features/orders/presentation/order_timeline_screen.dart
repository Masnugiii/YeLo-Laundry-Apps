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

class OrderTimelineScreen extends ConsumerStatefulWidget {
  const OrderTimelineScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderTimelineScreen> createState() => _OrderTimelineScreenState();
}

class _OrderTimelineScreenState extends ConsumerState<OrderTimelineScreen> {
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

  Map<String, dynamic>? _timelineData;
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
        repository.getTimeline(widget.orderId),
        repository.getOrder(widget.orderId),
      ]);

      if (!mounted) return;
      setState(() {
        _timelineData = results[0] as Map<String, dynamic>;
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

  List<_TimelineStep> _resolveTimelineSteps() {
    final timeline = (_timelineData?['timeline'] as List<dynamic>? ?? []);
    final history = (_timelineData?['statusHistory'] as List<dynamic>? ?? []);

    if (timeline.isNotEmpty) {
      return timeline.map((item) {
        final map = item as Map<String, dynamic>;
        return _TimelineStep(
          title: map['title']?.toString() ??
              map['label']?.toString() ??
              map['type']?.toString() ??
              'Event',
          subtitle: map['description']?.toString(),
          timestamp: map['createdAt']?.toString() ?? map['at']?.toString(),
        );
      }).toList();
    }

    return history.map((item) {
      final map = item as Map<String, dynamic>;
      final status = map['toStatus']?.toString() ??
          map['currentStatus']?.toString() ??
          '';
      return _TimelineStep(
        title: orderStatusDisplayLabel(status),
        subtitle: map['notes']?.toString(),
        timestamp: map['changedAt']?.toString() ?? map['createdAt']?.toString(),
      );
    }).toList();
  }

  _TimelineStepState _stepStateForIndex(int index, int total) {
    final orderStatus = _order?.orderStatus.toUpperCase() ?? '';
    if (orderStatus == 'COMPLETED' || orderStatus == 'CANCELLED') {
      return _TimelineStepState.completed;
    }
    if (index < total - 1) return _TimelineStepState.completed;
    return _TimelineStepState.current;
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
                      'Order Timeline',
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

  Widget _buildOrderCard(OrderDetail order) {
    final statusLabel = orderStatusDisplayLabel(order.orderStatus);
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
                  statusLabel,
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
            const SizedBox(height: AppSpacing.s12),
            _infoRow('Tanggal Pesanan', orderDateLabel),
          ],
          if (order.pickupRequired || order.deliveryRequired)
            _infoRow(
              'Antar Jemput',
              order.pickupRequired && order.deliveryRequired
                  ? 'Pickup & Delivery'
                  : order.pickupRequired
                      ? 'Pickup'
                      : 'Delivery',
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(List<_TimelineStep> steps) {
    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Pesanan',
            style: _poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          if (steps.isEmpty)
            Text(
              'Belum ada riwayat timeline untuk pesanan ini.',
              style: _poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final state = _stepStateForIndex(index, steps.length);
              final isLast = index == steps.length - 1;
              final timestampLabel = _formatDate(step.timestamp);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Column(
                        children: [
                          _TimelineNode(state: state),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: state == _TimelineStepState.completed
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: _poppins(
                                fontSize: 14,
                                fontWeight: state == _TimelineStepState.current
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: state == _TimelineStepState.current
                                    ? AppColors.brandBlue
                                    : state == _TimelineStepState.completed
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                              ),
                            ),
                            if (step.subtitle != null &&
                                step.subtitle!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.s4),
                              Text(
                                step.subtitle!,
                                style: _poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (timestampLabel != null) ...[
                              const SizedBox(height: AppSpacing.s4),
                              Text(
                                timestampLabel,
                                style: _poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
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

  Widget _buildContent() {
    final order = _order!;
    final steps = _resolveTimelineSteps();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        _buildOrderCard(order),
        const SizedBox(height: AppSpacing.s12),
        _buildTimelineCard(steps),
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
                        'Gagal memuat timeline pesanan',
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

enum _TimelineStepState { completed, current }

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    this.subtitle,
    this.timestamp,
  });

  final String title;
  final String? subtitle;
  final String? timestamp;
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.state});

  final _TimelineStepState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      _TimelineStepState.completed => Container(
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
      _TimelineStepState.current => Container(
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
    };
  }
}
