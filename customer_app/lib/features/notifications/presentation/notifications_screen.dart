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
import 'package:yelo_laundry_customer/features/notifications/presentation/utils/notification_category.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/widgets/notification_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<AppNotification> _items = [];
  bool _loading = true;
  bool _markingAll = false;
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
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result =
          await ref.read(notificationRepositoryProvider).getNotifications();
      if (!mounted) return;
      setState(() => _items..clear()..addAll(result.items));
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = messageFromError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAll) return;

    setState(() => _markingAll = true);
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      if (!mounted) return;
      setState(() {
        for (var i = 0; i < _items.length; i++) {
          _items[i] = _items[i].copyWith(isRead: true);
        }
      });
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageFromError(error))),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  Future<void> _handleNotificationTap(AppNotification item) async {
    if (!item.isRead) {
      await ref.read(notificationRepositoryProvider).markRead(item.id);
      if (mounted) {
        setState(() {
          final index = _items.indexWhere((entry) => entry.id == item.id);
          if (index != -1) {
            _items[index] = _items[index].copyWith(isRead: true);
          }
        });
      }
    }

    if (!mounted) return;
    await context.push('/notifications/${item.id}');
    if (mounted) await _load();
  }

  Widget _buildEmptyState() {
    return PickupDashboardCard(
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Belum Ada Notifikasi',
            style: _poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Notifikasi pesanan, pembayaran,\ndan laundry Anda akan muncul di sini.',
            style: _poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGroupHeader(NotificationTimeGroup group) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8, bottom: AppSpacing.s12),
      child: Text(
        group.label,
        style: _poppins(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(NotificationCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        category.label,
        style: _poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildGroupedList() {
    final groupedItems = buildGroupedNotificationList(_items);

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.brandBlue,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s8,
          AppSpacing.s16,
          AppSpacing.s24,
        ),
        itemCount: groupedItems.length,
        itemBuilder: (context, index) {
          final item = groupedItems[index];

          return switch (item) {
            NotificationTimeGroupHeaderItem(:final group) =>
              _buildTimeGroupHeader(group),
            NotificationCategoryHeaderItem(:final category) =>
              _buildCategoryHeader(category),
            NotificationEntryItem(:final notification, :final category) =>
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                child: NotificationCard(
                  notification: notification,
                  category: category,
                  onTap: () => _handleNotificationTap(notification),
                ),
              ),
          };
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const ApiLoadingView(message: 'Memuat notifikasi...');
    }

    if (_error != null && _items.isEmpty) {
      return ApiErrorView(message: _error!, onRetry: _load);
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [_buildEmptyState()],
      );
    }

    return _buildGroupedList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DashboardPageHeader(
            title: 'Notifikasi',
            showBack: true,
            onBack: () => context.go('/home'),
            actions: [
              IconButton(
                onPressed: _markingAll ? null : _markAllRead,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                tooltip: 'Tandai semua dibaca',
                icon: _markingAll
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.done_all, color: Colors.white),
              ),
            ],
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
