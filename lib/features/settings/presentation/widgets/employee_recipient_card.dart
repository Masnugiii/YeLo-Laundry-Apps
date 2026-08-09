import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/reminder_recipient_employee.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';

class EmployeeRecipientCard extends StatelessWidget {
  const EmployeeRecipientCard({
    super.key,
    required this.employee,
    required this.isSelected,
    required this.onSelectedChanged,
  });

  final ReminderRecipientEmployee employee;
  final bool isSelected;
  final ValueChanged<bool> onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: SettingsTheme.cardRadius,
        boxShadow: AppShadows.md(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: SettingsTheme.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  employee.initials,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    _RoleBadge(role: employee.role.label),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'WhatsApp',
                      style: SettingsTheme.tileDescriptionStyle,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      employee.whatsapp,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                onChanged: (value) => onSelectedChanged(value ?? false),
                activeColor: AppColors.primary,
                checkColor: AppColors.onPrimary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Text(
        role,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
