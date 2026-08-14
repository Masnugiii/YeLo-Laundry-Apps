import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/binatu_attendance_history_screen.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/binatu_attendance_cards.dart';
import 'package:yelo_laundry_erp/features/attendance/providers/binatu_attendance_provider.dart';
import 'package:yelo_laundry_erp/features/dashboard/presentation/widgets/back_to_dashboard_link.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class BinatuAttendanceScreen extends ConsumerWidget {
  const BinatuAttendanceScreen({
    super.key,
    this.showBackButton = true,
    this.showBackToDashboard = false,
  });

  final bool showBackButton;
  final bool showBackToDashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(binatuAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading:
            showBackButton && !showBackToDashboard,
        leading: showBackToDashboard
            ? const DashboardAppBarBackButton()
            : null,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Kehadiran',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: attendanceState.when(
        loading: () => const ApiLoadingView(message: 'Memuat kehadiran...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(binatuAttendanceProvider),
        ),
        data: (attendance) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s20,
            AppSpacing.s32,
          ),
          children: [
            BinatuAttendanceProfileCard(profile: attendance.profile),
            const SizedBox(height: AppSpacing.s16),
            BinatuTodayAttendanceCard(today: attendance.today),
            const SizedBox(height: AppSpacing.s16),
            BinatuEpposReadyCard(deviceId: attendance.epposDeviceId),
            const SizedBox(height: AppSpacing.s24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: attendance.canCheckIn
                        ? () => _handleCheckIn(context, ref)
                        : null,
                    icon: const Icon(Icons.login),
                    label: Text(
                      'Check In',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.35),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: attendance.canCheckOut
                        ? () => _handleCheckOut(context, ref)
                        : null,
                    icon: const Icon(Icons.logout),
                    label: Text(
                      'Check Out',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.accent.withValues(alpha: 0.35),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => BinatuAttendanceHistoryScreen(
                        history: attendance.history,
                        employeeName: attendance.profile.name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.history, color: AppColors.primary),
                label: Text(
                  'Riwayat Kehadiran',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(binatuAttendanceProvider.notifier).checkIn();
      if (context.mounted) {
        _showSnackBar(context, 'Check In berhasil dicatat.');
      }
    } catch (error) {
      if (context.mounted) {
        _showSnackBar(
          context,
          messageFromError(error),
          isError: true,
        );
      }
    }
  }

  Future<void> _handleCheckOut(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(binatuAttendanceProvider.notifier).checkOut();
      if (context.mounted) {
        _showSnackBar(context, 'Check Out berhasil dicatat.');
      }
    } catch (error) {
      if (context.mounted) {
        _showSnackBar(
          context,
          messageFromError(error),
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
