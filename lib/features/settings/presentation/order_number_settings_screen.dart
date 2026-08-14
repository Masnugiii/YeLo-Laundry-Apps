import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_settings_config.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/order_number_info_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/order_number_save_confirmation_dialog.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';

class OrderNumberSettingsScreen extends ConsumerStatefulWidget {
  const OrderNumberSettingsScreen({
    super.key,
    this.readOnly = false,
  });

  final bool readOnly;

  @override
  ConsumerState<OrderNumberSettingsScreen> createState() =>
      _OrderNumberSettingsScreenState();
}

class _OrderNumberSettingsScreenState
    extends ConsumerState<OrderNumberSettingsScreen> {
  final _queueNumberController = TextEditingController();
  final _prefixController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _queueNumberController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  void _applyConfig(QueueNumberingConfig config) {
    _prefixController.text = config.prefix;
    _queueNumberController.text = config.startingNumber.toString();
  }

  Future<void> _onSavePressed() async {
    final confirmed = await showOrderNumberSaveConfirmationDialog(context);
    if (confirmed != true || !mounted) return;

    final startingNumber = int.tryParse(_queueNumberController.text.trim());
    if (startingNumber == null || startingNumber < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor antrian awal tidak valid.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await ref.read(settingsRepositoryProvider).updateQueueNumbering(
            QueueNumberingConfig(
              prefix: _prefixController.text.trim().isEmpty
                  ? 'A'
                  : _prefixController.text.trim(),
              startingNumber: startingNumber,
              dailyReset: true,
            ),
          );

      ref.invalidate(queueNumberingProvider);
      if (!mounted) return;

      _applyConfig(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Penomoran order berhasil disimpan.\n'
            'Order berikutnya akan dimulai dari ${updated.formattedNextQueueNumber}.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onPrimary,
              height: 1.4,
            ),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan penomoran order.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueNumberingProvider);

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
      body: queueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(error.toString()),
                const SizedBox(height: AppSpacing.s16),
                FilledButton(
                  onPressed: () => ref.invalidate(queueNumberingProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (config) {
          if (_queueNumberController.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _applyConfig(config));
            });
          }

          return Column(
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
                              'yang digunakan sebelum memakai Yelo Laundry ERP.',
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
                            'Prefix Antrian',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s8),
                          TextFormField(
                            controller: _prefixController,
                            readOnly: widget.readOnly,
                            enabled: !widget.readOnly,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: SettingsTheme.textFieldDecoration,
                          ),
                          const SizedBox(height: AppSpacing.s16),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: SettingsTheme.textFieldDecoration.copyWith(
                              hintText: '4288',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Text(
                            'Nomor berikutnya: ${config.formattedNextQueueNumber}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      onPressed: _isSaving ? null : _onSavePressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : Text(
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
          );
        },
      ),
    );
  }
}
