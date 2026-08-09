import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/data/dummy_order_number_settings.dart';
import 'package:yelo_laundry_erp/features/settings/models/order_number_settings.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/order_number_info_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/order_number_save_confirmation_dialog.dart';

class OrderNumberSettingsScreen extends StatefulWidget {
  const OrderNumberSettingsScreen({
    super.key,
    this.readOnly = false,
  });

  final bool readOnly;

  @override
  State<OrderNumberSettingsScreen> createState() =>
      _OrderNumberSettingsScreenState();
}

class _OrderNumberSettingsScreenState extends State<OrderNumberSettingsScreen> {
  late final TextEditingController _queueNumberController;
  late OrderNumberSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = getOrderNumberSettings();
    _queueNumberController = TextEditingController(
      text: _settings.startingQueueNumber,
    );
  }

  @override
  void dispose() {
    _queueNumberController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    final confirmed = await showOrderNumberSaveConfirmationDialog(context);
    if (confirmed != true || !mounted) return;

    final startingNumber = _queueNumberController.text.trim();
    saveOrderNumberSettings(startingNumber);
    _settings = getOrderNumberSettings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          'Penomoran order berhasil disimpan.\n'
          'Order berikutnya akan dimulai dari ${_settings.formattedNextQueueNumber}.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onPrimary,
            height: 1.4,
          ),
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
          widget.readOnly ? 'Penomoran Order (Lihat Saja)' : 'Penomoran Order',
          style: GoogleFonts.poppins(
            fontSize: 22,
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
                if (widget.readOnly)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Text(
                            'Mode lihat saja. Hanya Owner yang dapat mengubah penomoran order.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  widget.readOnly
                      ? 'Nomor antrian saat ini yang digunakan sistem.'
                      : 'Masukkan nomor antrian awal sesuai dengan nomor order terakhir '
                          'yang digunakan sebelum memakai Yelo Laundry ERP.\n\n'
                          'Pengaturan ini hanya dilakukan satu kali.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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
                        'Nomor Antrian Awal',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      TextFormField(
                        controller: _queueNumberController,
                        readOnly: widget.readOnly,
                        enabled: !widget.readOnly,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        decoration: SettingsTheme.textFieldDecoration.copyWith(
                          hintText: '4288',
                          filled: widget.readOnly,
                          fillColor: widget.readOnly
                              ? AppColors.dashboardBackground
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.readOnly) ...[
                  const SizedBox(height: AppSpacing.s16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    decoration: SettingsTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contoh:',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Text(
                          'Jika order terakhir Anda adalah A-4287,\n\n'
                          'maka masukkan:\n\n'
                          '4288\n\n'
                          'Order berikutnya akan otomatis menjadi:\n\n'
                          'A-4288\n'
                          'A-4289\n'
                          'A-4290\n\n'
                          'dan seterusnya.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                OrderNumberInfoCard(readOnly: widget.readOnly),
              ],
            ),
          ),
          if (!widget.readOnly)
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
                  onPressed: _onSavePressed,
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
