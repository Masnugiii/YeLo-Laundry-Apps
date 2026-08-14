import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_settings_config.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_customization_settings.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/laundry_profile_source_info_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/receipt_customization_preview.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/receipt_customization_section_card.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';

class ReceiptCustomizationScreen extends ConsumerStatefulWidget {
  const ReceiptCustomizationScreen({super.key});

  @override
  ConsumerState<ReceiptCustomizationScreen> createState() =>
      _ReceiptCustomizationScreenState();
}

class _ReceiptCustomizationScreenState
    extends ConsumerState<ReceiptCustomizationScreen> {
  ReceiptCustomizationSettings _settings = const ReceiptCustomizationSettings();
  ReceiptSettingsConfig? _receiptConfig;
  late final TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _applyReceiptConfig(ReceiptSettingsConfig config) {
    _receiptConfig = config;
    _noteController.text = config.footerText ?? '';
    _settings = _settings.copyWith(
      business: _settings.business.copyWith(showLogo: config.showLogo),
      showQrCode: config.showQRCode,
      receiptNote: config.footerText ?? '',
    );
  }

  void _update(ReceiptCustomizationSettings settings) {
    setState(() => _settings = settings);
  }

  Future<void> _onSave() async {
    if (_isSaving || !ref.read(isOwnerSettingsProvider)) return;

    setState(() => _isSaving = true);

    try {
      final updated = await ref.read(settingsRepositoryProvider).updateReceiptSettings(
            ReceiptSettingsConfig(
              showLogo: _settings.business.showLogo,
              showQRCode: _settings.showQrCode,
              footerText: _noteController.text.trim(),
              companyName: _receiptConfig?.companyName ?? '',
              companyPhone: _receiptConfig?.companyPhone,
              companyAddress: _receiptConfig?.companyAddress,
              companyLogoUrl: _receiptConfig?.companyLogoUrl,
            ).toUpdatePayload(
              showLogo: _settings.business.showLogo,
              showQRCode: _settings.showQrCode,
              footerText: _noteController.text.trim(),
            ),
          );

      ref.invalidate(receiptSettingsProvider);
      if (!mounted) return;
      _applyReceiptConfig(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Pengaturan struk berhasil disimpan.',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Gagal menyimpan pengaturan struk.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final receiptAsync = ref.watch(receiptSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Kustomisasi Struk',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: receiptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s16),
                FilledButton(
                  onPressed: () => ref.invalidate(receiptSettingsProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (config) {
          if (_receiptConfig?.companyName != config.companyName) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _applyReceiptConfig(config));
              }
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
                    _section1(config),
                    const SizedBox(height: AppSpacing.s16),
                    _section8(),
                    const SizedBox(height: AppSpacing.s16),
                    _section9(),
                    const SizedBox(height: AppSpacing.s16),
                    _section12(config),
                  ],
                ),
              ),
              if (canEdit) _saveButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _section1(ReceiptSettingsConfig config) {
    final b = _settings.business;
    return ReceiptCustomizationSectionCard(
      title: 'Informasi Laundry',
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s8,
            AppSpacing.s20,
            AppSpacing.s16,
          ),
          child: LaundryProfileSourceInfoCard(),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Logo Laundry',
          value: b.showLogo,
          onChanged: canEdit
              ? (v) => _update(_settings.copyWith(
                    business: b.copyWith(showLogo: v),
                  ))
              : (_) {},
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Nama Laundry',
          value: true,
          onChanged: (_) {},
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Alamat Laundry',
          value: config.companyAddress?.isNotEmpty == true,
          onChanged: (_) {},
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Nomor WhatsApp',
          value: config.companyPhone?.isNotEmpty == true,
          onChanged: (_) {},
          showDivider: false,
        ),
      ],
    );
  }

  bool get canEdit => ref.read(isOwnerSettingsProvider);

  Widget _section8() {
    return ReceiptCustomizationSectionCard(
      title: 'QR Code',
      description:
          'QR Code dapat digunakan untuk melihat status laundry di masa mendatang.',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan QR Code',
          value: _settings.showQrCode,
          showDivider: false,
          onChanged: canEdit
              ? (v) => _update(_settings.copyWith(showQrCode: v))
              : (_) {},
        ),
      ],
    );
  }

  Widget _section9() {
    return ReceiptCustomizationSectionCard(
      title: 'Catatan Struk',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s8,
            AppSpacing.s20,
            AppSpacing.s20,
          ),
          child: TextFormField(
            controller: _noteController,
            maxLines: 4,
            readOnly: !canEdit,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: SettingsTheme.textFieldDecoration.copyWith(
              hintText: 'Masukkan catatan struk...',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _section12(ReceiptSettingsConfig config) {
    return ReceiptCustomizationSectionCard(
      title: 'Preview Struk',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s8,
            AppSpacing.s20,
            AppSpacing.s20,
          ),
          child: ReceiptCustomizationPreview(
            settings: _settings.copyWith(
              receiptNote: _noteController.text,
            ),
            receiptConfig: config,
          ),
        ),
      ],
    );
  }

  Widget _saveButton() {
    return Container(
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
          onPressed: _isSaving ? null : _onSave,
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
                  'Simpan Pengaturan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
