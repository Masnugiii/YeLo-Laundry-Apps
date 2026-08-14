import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/widgets/notification_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  AppNotification? _notification;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final notification = await ref
          .read(notificationRepositoryProvider)
          .getDetail(widget.notificationId);

      await ref
          .read(notificationRepositoryProvider)
          .markRead(widget.notificationId);

      if (!mounted) return;
      setState(() {
        _notification = notification;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = messageFromError(error);
      });
    }
  }

  void _openRelatedDestination(AppNotification item) {
    final type = item.type.toUpperCase();
    final orderId = item.orderId;

    switch (type) {
      case 'ORDER':
      case 'PICKUP':
      case 'LAUNDRY':
        if (orderId != null && orderId.isNotEmpty) {
          context.push('/orders/$orderId');
        }
        return;
      case 'PAYMENT':
        if (orderId != null && orderId.isNotEmpty) {
          context.push('/orders/$orderId/payment');
        }
        return;
      case 'WALLET':
        context.push('/wallet');
        return;
      case 'PROMO':
        context.push('/promo');
        return;
      case 'POINT':
      case 'REWARD':
        context.push('/rewards');
        return;
      default:
        return;
    }
  }

  Widget _buildEmptyState() {
    return PickupDashboardCard(
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 40,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Notifikasi tidak ditemukan',
            style: _poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(AppNotification item) {
    final date = NotificationFormat.parseDate(item.createdAt);
    final timestamp = date == null
        ? item.createdAt
        : NotificationFormat.detailDateTime(date);

    return PickupDashboardCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              NotificationFormat.iconForType(item.type),
              size: 18,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: _poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  item.message,
                  style: _poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  timestamp,
                  style: _poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const ApiLoadingView(message: 'Memuat detail notifikasi...');
    }

    if (_error != null) {
      return ApiErrorView(message: _error!, onRetry: _load);
    }

    final item = _notification;
    if (item == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [_buildEmptyState()],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        _buildDetailCard(item),
        if (_hasRelatedDestination(item)) ...[
          const SizedBox(height: AppSpacing.s16),
          FilledButton(
            onPressed: () => _openRelatedDestination(item),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.brandBlue,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              _relatedDestinationLabel(item),
              style: _poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool _hasRelatedDestination(AppNotification item) {
    final type = item.type.toUpperCase();
    if (type == 'WALLET' || type == 'PROMO' || type == 'POINT' || type == 'REWARD') {
      return true;
    }
    return item.orderId != null && item.orderId!.isNotEmpty;
  }

  String _relatedDestinationLabel(AppNotification item) {
    switch (item.type.toUpperCase()) {
      case 'ORDER':
      case 'PICKUP':
      case 'LAUNDRY':
        return 'Lihat Pesanan';
      case 'PAYMENT':
        return 'Lihat Pembayaran';
      case 'WALLET':
        return 'Buka Wallet';
      case 'PROMO':
        return 'Lihat Promo';
      case 'POINT':
      case 'REWARD':
        return 'Lihat Rewards';
      default:
        return 'Buka Halaman Terkait';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Detail Notifikasi'),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
