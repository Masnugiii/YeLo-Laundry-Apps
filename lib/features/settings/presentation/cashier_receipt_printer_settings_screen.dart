import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/shared/widgets/selectable_chip.dart';

class CashierReceiptPrinterSettingsScreen extends StatefulWidget {
  const CashierReceiptPrinterSettingsScreen({super.key});

  @override
  State<CashierReceiptPrinterSettingsScreen> createState() =>
      _CashierReceiptPrinterSettingsScreenState();
}

class _CashierReceiptPrinterSettingsScreenState
    extends State<CashierReceiptPrinterSettingsScreen> {
  static const _printers = [
    'Printer Thermal Default',
    'Epson TM-T82',
    'Bluetooth Printer',
  ];

  String _selectedPrinter = _printers.first;
  String _paperSize = '58 mm';

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Pengaturan printer disimpan (dummy).',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Pengaturan Struk',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                Text(
                  'Kasir dapat memilih printer dan ukuran kertas struk. '
                  'Logo, profil laundry, dan layout struk hanya dapat diubah oleh Owner.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: SettingsTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Printer',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      DropdownMenu<String>(
                        width: double.infinity,
                        initialSelection: _selectedPrinter,
                        onSelected: (value) {
                          if (value != null) {
                            setState(() => _selectedPrinter = value);
                          }
                        },
                        dropdownMenuEntries: [
                          for (final printer in _printers)
                            DropdownMenuEntry(value: printer, label: printer),
                        ],
                        textStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: SettingsTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ukuran Kertas',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        children: [
                          SelectableChip(
                            label: '58 mm',
                            isSelected: _paperSize == '58 mm',
                            onTap: () => setState(() => _paperSize = '58 mm'),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          SelectableChip(
                            label: '80 mm',
                            isSelected: _paperSize == '80 mm',
                            onTap: () => setState(() => _paperSize = '80 mm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s24,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
