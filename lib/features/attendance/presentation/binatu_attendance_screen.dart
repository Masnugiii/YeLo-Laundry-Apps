import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/binatu_attendance_history_screen.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/widgets/binatu_attendance_cards.dart';
import 'package:yelo_laundry_erp/features/attendance/providers/binatu_attendance_provider.dart';

class BinatuAttendanceScreen extends ConsumerWidget {
  const BinatuAttendanceScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(binatuAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
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
      body: ListView(
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
                      ? () {
                          ref.read(binatuAttendanceProvider.notifier).checkIn();
                          _showSnackBar(context, 'Check In berhasil dicatat.');
                        }
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
                      ? () {
                          ref.read(binatuAttendanceProvider.notifier).checkOut();
                          _showSnackBar(context, 'Check Out berhasil dicatat.');
                        }
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
                'Attendance History',
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
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
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
