import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/attendance/models/attendance_models.dart';
import 'package:yelo_laundry_erp/features/attendance/presentation/attendance_theme.dart';

class EpposIntegrationCard extends StatelessWidget {
  const EpposIntegrationCard({
    super.key,
    required this.syncStatus,
  });

  final EpposSyncStatus syncStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: AttendanceTheme.cardDecoration.copyWith(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Integrasi EPPOS',
                      style: AttendanceTheme.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Siap untuk sinkronisasi fingerprint',
                      style: AttendanceTheme.labelStyle,
                    ),
                  ],
                ),
              ),
              _StatusChip(isConnected: syncStatus.isConnected),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          _InfoRow(label: 'Perangkat', value: syncStatus.deviceName),
          const SizedBox(height: AppSpacing.s8),
          _InfoRow(
            label: 'Terakhir Sinkron',
            value: formatAttendanceSyncTime(syncStatus.lastSyncedAt),
          ),
          const SizedBox(height: AppSpacing.s8),
          _InfoRow(
            label: 'Data Tertunda',
            value: '${syncStatus.pendingRecords} record',
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isConnected ? 'Terhubung' : 'Offline',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isConnected
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AttendanceTheme.labelStyle),
        ),
        Expanded(
          child: Text(value, style: AttendanceTheme.valueStyle),
        ),
      ],
    );
  }
}
