import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/employee_recipient_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/reminder_recipient_info_card.dart';
import 'package:yelo_laundry_erp/features/settings/providers/reminder_recipient_provider.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class ReminderRecipientSection extends ConsumerWidget {
  const ReminderRecipientSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  void _toggleEmployee(String employeeId, bool isSelected) {
    final updated = Set<String>.from(settings.resolvedSelectedReminderRecipientIds);
    if (isSelected) {
      updated.add(employeeId);
    } else {
      updated.remove(employeeId);
    }
    onChanged(settings.copyWith(selectedReminderRecipientIds: updated));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(reminderRecipientEmployeesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reminder Recipient',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          'Pilih siapa saja yang akan menerima pengingat operasional melalui WhatsApp dan Notifikasi Aplikasi.',
          style: SettingsTheme.tileDescriptionStyle.copyWith(fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.s16),
        employeesAsync.when(
          loading: () => const ApiLoadingView(
            message: 'Memuat daftar karyawan...',
          ),
          error: (error, _) => ApiErrorView(
            message: messageFromError(error),
            onRetry: () => ref.invalidate(reminderRecipientEmployeesProvider),
          ),
          data: (employees) {
            if (employees.isEmpty) {
              return Text(
                'Belum ada karyawan Owner/Manajer aktif.',
                style: SettingsTheme.tileDescriptionStyle,
              );
            }

            return Column(
              children: [
                for (var i = 0; i < employees.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  EmployeeRecipientCard(
                    employee: employees[i],
                    isSelected: settings.resolvedSelectedReminderRecipientIds
                        .contains(employees[i].id),
                    onSelectedChanged: (value) => _toggleEmployee(
                      employees[i].id,
                      value,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.s16),
        const ReminderRecipientInfoCard(),
        const SizedBox(height: AppSpacing.s16),
        OutlinedButton(
          onPressed: () => context.push('/employee-master'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Buka Master Karyawan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
