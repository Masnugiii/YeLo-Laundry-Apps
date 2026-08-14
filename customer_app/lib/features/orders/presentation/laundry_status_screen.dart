import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/presentation/widgets/laundry_active_order_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';



class LaundryStatusScreen extends ConsumerStatefulWidget {
  const LaundryStatusScreen({super.key});

  @override
  ConsumerState<LaundryStatusScreen> createState() => _LaundryStatusScreenState();
}

class _LaundryStatusScreenState extends ConsumerState<LaundryStatusScreen> {
  final List<OrderItem> _activeOrders = [];
  final Map<String, List<LaundryTrackingStep>> _trackingByOrderId = {};
  bool _loading = true;
  String? _error;

  static const _terminalStatuses = {'COMPLETED', 'CANCELLED'};

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

  bool _isActiveOrder(String status) {
    return !_terminalStatuses.contains(status.toUpperCase());
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
      final result = await ref.read(orderRepositoryProvider).getOrders(page: 1);
      final active = result.items.where((o) => _isActiveOrder(o.orderStatus)).toList();
      final tracking = <String, List<LaundryTrackingStep>>{};

      await Future.wait(
        active.map((order) async {
          try {
            tracking[order.id] =
                await ref.read(orderRepositoryProvider).getLaundryTracking(order.id);
          } catch (_) {
            tracking[order.id] = [];
          }
        }),
      );

      if (!mounted) return;
      setState(() {
        _activeOrders
          ..clear()
          ..addAll(active);
        _trackingByOrderId
          ..clear()
          ..addAll(tracking);
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildHeader() {
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
                    onPressed: () => context.go('/home'),
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
                      'Cek Status Laundry',
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
              const SizedBox(height: AppSpacing.s4),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s8),
                child: Text(
                  'Pantau proses pesanan laundry kamu',
                  style: _poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
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
                        'Gagal memuat status laundry',
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
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppColors.brandBlue,
              child: _activeOrders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      children: [
                        PickupDashboardCard(
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_laundry_service_outlined,
                                size: 48,
                                color: AppColors.textSecondary.withValues(alpha: 0.45),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              Text(
                                'Belum ada pesanan laundry yang sedang berjalan',
                                style: _poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.s16),
                              OutlinedButton(
                                onPressed: () => context.push('/orders'),
                                child: const Text('Lihat semua pesanan'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16,
                        AppSpacing.s12,
                        AppSpacing.s16,
                        AppSpacing.s16,
                      ),
                      itemCount: _activeOrders.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.s12),
                      itemBuilder: (context, index) {
                        final order = _activeOrders[index];
                        final steps = _trackingByOrderId[order.id] ?? [];

                        return LaundryActiveOrderCard(
                          key: ValueKey(order.id),
                          order: order,
                          steps: steps,
                          onTap: () => context.push('/orders/${order.id}/tracking'),
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
