import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_menu_badge_actions.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/widgets/api_notification_card.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/widgets/laundry_job_accepted_notification_card.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/widgets/operator_assistance_notification_card.dart';
import 'package:yelo_laundry_erp/features/notifications/providers/app_notification_provider.dart';
import 'package:yelo_laundry_erp/features/notifications/providers/notification_list_provider.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(userRoleProvider);
      markNotificationCenterBadgeRead(ref, role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    final notificationState = ref.watch(notificationListProvider);
    final localState = ref.watch(appNotificationProvider);

    final laundryJobs = localState.laundryJobNotifications.toList()
      ..sort((a, b) => b.acceptedAt.compareTo(a.acceptedAt));
    final operatorAssistance = ref
        .read(appNotificationProvider.notifier)
        .operatorAssistanceForOperators();

    final showLaundryJobs = role == UserRole.cashier ||
        role == UserRole.cashierLaundry ||
        role == UserRole.cashierLaundryDriver ||
        role == UserRole.owner;
    final showOperatorAssistance = role == UserRole.cashierLaundry ||
        role == UserRole.cashierLaundryDriver;

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Notification Center',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationListProvider.notifier).markAllRead(),
            child: const Text(
              'Tandai semua',
              style: TextStyle(color: AppColors.onPrimary),
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(notificationListProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: notificationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            'Gagal memuat notifikasi.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        data: (state) {
          final apiNotifications = state.items;
          final isEmpty = apiNotifications.isEmpty &&
              (showLaundryJobs ? laundryJobs.isEmpty : true) &&
              (showOperatorAssistance ? operatorAssistance.isEmpty : true);

          if (isEmpty) {
            return Center(
              child: Text(
                'Belum ada notifikasi.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationListProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                Text(
                  role == UserRole.laundry
                      ? 'Notifikasi pekerjaan setrika dan deadline hari ini.'
                      : role == UserRole.owner
                          ? 'Notifikasi operasional laundry terbaru.'
                          : 'Notifikasi transaksi dan pekerjaan laundry terbaru.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (showOperatorAssistance && operatorAssistance.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s16),
                  for (var i = 0; i < operatorAssistance.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.s12),
                    OperatorAssistanceNotificationCard(
                      notification: operatorAssistance[i],
                    ),
                  ],
                ],
                if (showLaundryJobs && laundryJobs.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s16),
                  for (var i = 0; i < laundryJobs.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.s12),
                    LaundryJobAcceptedNotificationCard(
                      notification: laundryJobs[i],
                    ),
                  ],
                ],
                if (apiNotifications.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s16),
                  for (var i = 0; i < apiNotifications.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.s12),
                    ApiNotificationCard(
                      title: apiNotifications[i]['title'] as String? ?? '-',
                      message: apiNotifications[i]['message'] as String? ?? '',
                      type: apiNotifications[i]['type'] as String? ?? 'SYSTEM',
                      createdAt: DateTime.tryParse(
                            apiNotifications[i]['createdAt'] as String? ?? '',
                          ) ??
                          DateTime.now(),
                      isRead: apiNotifications[i]['isRead'] as bool? ?? false,
                      onMarkRead: (apiNotifications[i]['isRead'] as bool? ??
                              false)
                          ? null
                          : () => ref
                              .read(notificationListProvider.notifier)
                              .markRead(apiNotifications[i]['id'] as String),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
