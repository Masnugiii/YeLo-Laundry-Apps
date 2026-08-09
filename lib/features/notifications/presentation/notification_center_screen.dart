import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/role/role.dart';
import 'package:yelo_laundry_erp/core/session/session_provider.dart';
import 'package:yelo_laundry_erp/features/binatu/presentation/widgets/binatu_notification_card.dart';
import 'package:yelo_laundry_erp/features/binatu/providers/binatu_notification_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/models/user_role.dart';
import 'package:yelo_laundry_erp/features/dashboard/providers/dashboard_menu_badge_actions.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/widgets/cashier_transaction_notification_card.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/widgets/laundry_job_accepted_notification_card.dart';
import 'package:yelo_laundry_erp/features/notifications/presentation/widgets/operator_assistance_notification_card.dart';
import 'package:yelo_laundry_erp/features/notifications/providers/app_notification_provider.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);

    if (role == UserRole.laundry) {
      return const _BinatuNotificationCenter();
    }

    return _CashierOwnerNotificationCenter(role: role);
  }
}

class _BinatuNotificationCenter extends ConsumerWidget {
  const _BinatuNotificationCenter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = [...ref.watch(binatuNotificationProvider)]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text(
                'Belum ada notifikasi.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                Text(
                  'Notifikasi pekerjaan setrika dan deadline hari ini.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                for (var i = 0; i < notifications.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  BinatuNotificationCard(notification: notifications[i]),
                ],
              ],
            ),
    );
  }
}

class _CashierOwnerNotificationCenter extends ConsumerStatefulWidget {
  const _CashierOwnerNotificationCenter({
    required this.role,
  });

  final UserRole role;

  @override
  ConsumerState<_CashierOwnerNotificationCenter> createState() =>
      _CashierOwnerNotificationCenterState();
}

class _CashierOwnerNotificationCenterState
    extends ConsumerState<_CashierOwnerNotificationCenter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      markNotificationCenterBadgeRead(ref, widget.role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(appNotificationProvider);
    final laundryJobs =
        notificationState.laundryJobNotifications.toList()
          ..sort((a, b) => b.acceptedAt.compareTo(a.acceptedAt));
    final operatorAssistance = ref
        .read(appNotificationProvider.notifier)
        .operatorAssistanceForOperators();
    final transactions = notificationState.transactionNotifications.toList()
      ..sort((a, b) => b.transactionAt.compareTo(a.transactionAt));

    final showTransactions = widget.role == UserRole.cashier ||
        widget.role == UserRole.cashierLaundry ||
        widget.role == UserRole.cashierLaundryDriver;
    final showLaundryJobs = widget.role == UserRole.cashier ||
        widget.role == UserRole.cashierLaundry ||
        widget.role == UserRole.cashierLaundryDriver ||
        widget.role == UserRole.owner;
    final showOperatorAssistance = widget.role == UserRole.cashierLaundry ||
        widget.role == UserRole.cashierLaundryDriver;

    final isEmpty = (showTransactions ? transactions.isEmpty : true) &&
        (showLaundryJobs ? laundryJobs.isEmpty : true) &&
        (showOperatorAssistance ? operatorAssistance.isEmpty : true);

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
      ),
      body: isEmpty
          ? Center(
              child: Text(
                'Belum ada notifikasi.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                Text(
                  widget.role == UserRole.owner
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
                if (showTransactions && transactions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s16),
                  for (var i = 0; i < transactions.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.s12),
                    CashierTransactionNotificationCard(
                      notification: transactions[i],
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}
