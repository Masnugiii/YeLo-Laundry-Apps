import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/data/dummy_receipt_customization_settings.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_customization_settings.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/laundry_profile_source_info_card.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/receipt_customization_preview.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/receipt_customization_section_card.dart';

class ReceiptCustomizationScreen extends StatefulWidget {
  const ReceiptCustomizationScreen({super.key});

  @override
  State<ReceiptCustomizationScreen> createState() =>
      _ReceiptCustomizationScreenState();
}

class _ReceiptCustomizationScreenState extends State<ReceiptCustomizationScreen> {
  late ReceiptCustomizationSettings _settings;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _settings = getReceiptCustomizationSettings();
    _noteController = TextEditingController(text: _settings.receiptNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _update(ReceiptCustomizationSettings settings) {
    setState(() => _settings = settings);
  }

  void _onSave() {
    saveReceiptCustomizationSettings(
      _settings.copyWith(receiptNote: _noteController.text),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Pengaturan struk berhasil disimpan.',
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
          'Kustomisasi Struk',
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
                _section1(),
                const SizedBox(height: AppSpacing.s16),
                _section2(),
                const SizedBox(height: AppSpacing.s16),
                _section3(),
                const SizedBox(height: AppSpacing.s16),
                _section4(),
                const SizedBox(height: AppSpacing.s16),
                _section5(),
                const SizedBox(height: AppSpacing.s16),
                _section6(),
                const SizedBox(height: AppSpacing.s16),
                _section7(),
                const SizedBox(height: AppSpacing.s16),
                _section8(),
                const SizedBox(height: AppSpacing.s16),
                _section9(),
                const SizedBox(height: AppSpacing.s16),
                _section10(),
                const SizedBox(height: AppSpacing.s16),
                _section11(),
                const SizedBox(height: AppSpacing.s16),
                _section12(),
              ],
            ),
          ),
          _saveButton(),
        ],
      ),
    );
  }

  Widget _section1() {
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
          onChanged: (v) => _update(_settings.copyWith(
            business: b.copyWith(showLogo: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Nama Laundry',
          value: b.showName,
          onChanged: (v) => _update(_settings.copyWith(
            business: b.copyWith(showName: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Alamat Laundry',
          value: b.showAddress,
          onChanged: (v) => _update(_settings.copyWith(
            business: b.copyWith(showAddress: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Nomor WhatsApp',
          value: b.showWhatsapp,
          onChanged: (v) => _update(_settings.copyWith(
            business: b.copyWith(showWhatsapp: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Instagram',
          value: b.showInstagram,
          onChanged: (v) => _update(_settings.copyWith(
            business: b.copyWith(showInstagram: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tampilkan Website',
          value: b.showWebsite,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            business: b.copyWith(showWebsite: v),
          )),
        ),
      ],
    );
  }

  Widget _section2() {
    final o = _settings.order;
    return ReceiptCustomizationSectionCard(
      title: 'Informasi Order',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Nomor Order',
          value: o.showOrderNumber,
          onChanged: (v) => _update(_settings.copyWith(
            order: o.copyWith(showOrderNumber: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Nomor Antrian',
          value: o.showQueueNumber,
          onChanged: (v) => _update(_settings.copyWith(
            order: o.copyWith(showQueueNumber: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Tanggal Order',
          value: o.showOrderDate,
          onChanged: (v) => _update(_settings.copyWith(
            order: o.copyWith(showOrderDate: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Estimasi Selesai',
          value: o.showEstimatedFinish,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            order: o.copyWith(showEstimatedFinish: v),
          )),
        ),
      ],
    );
  }

  Widget _section3() {
    final c = _settings.customer;
    return ReceiptCustomizationSectionCard(
      title: 'Informasi Customer',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Nama Customer',
          value: c.showCustomerName,
          onChanged: (v) => _update(_settings.copyWith(
            customer: c.copyWith(showCustomerName: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Nomor HP',
          value: c.showPhone,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            customer: c.copyWith(showPhone: v),
          )),
        ),
      ],
    );
  }

  Widget _section4() {
    final s = _settings.service;
    return ReceiptCustomizationSectionCard(
      title: 'Informasi Layanan',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Nama Layanan',
          value: s.showServiceName,
          onChanged: (v) => _update(_settings.copyWith(
            service: s.copyWith(showServiceName: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Berat Laundry',
          value: s.showWeight,
          onChanged: (v) => _update(_settings.copyWith(
            service: s.copyWith(showWeight: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Harga per Layanan',
          value: s.showPrice,
          onChanged: (v) => _update(_settings.copyWith(
            service: s.copyWith(showPrice: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Subtotal',
          value: s.showSubtotal,
          onChanged: (v) => _update(_settings.copyWith(
            service: s.copyWith(showSubtotal: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Diskon',
          value: s.showDiscount,
          onChanged: (v) => _update(_settings.copyWith(
            service: s.copyWith(showDiscount: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Grand Total',
          value: s.showGrandTotal,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            service: s.copyWith(showGrandTotal: v),
          )),
        ),
      ],
    );
  }

  Widget _section5() {
    final p = _settings.payment;
    return ReceiptCustomizationSectionCard(
      title: 'Pembayaran',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Metode Pembayaran',
          value: p.showPaymentMethod,
          onChanged: (v) => _update(_settings.copyWith(
            payment: p.copyWith(showPaymentMethod: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Status Pembayaran',
          value: p.showPaymentStatus,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            payment: p.copyWith(showPaymentStatus: v),
          )),
        ),
      ],
    );
  }

  Widget _section6() {
    final pd = _settings.pickupDelivery;
    return ReceiptCustomizationSectionCard(
      title: 'Pickup & Delivery',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Pickup',
          value: pd.showPickup,
          onChanged: (v) => _update(_settings.copyWith(
            pickupDelivery: pd.copyWith(showPickup: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Delivery',
          value: pd.showDelivery,
          onChanged: (v) => _update(_settings.copyWith(
            pickupDelivery: pd.copyWith(showDelivery: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Jadwal Pickup',
          value: pd.showPickupSchedule,
          onChanged: (v) => _update(_settings.copyWith(
            pickupDelivery: pd.copyWith(showPickupSchedule: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'Jadwal Delivery',
          value: pd.showDeliverySchedule,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            pickupDelivery: pd.copyWith(showDeliverySchedule: v),
          )),
        ),
      ],
    );
  }

  Widget _section7() {
    final e = _settings.employee;
    return ReceiptCustomizationSectionCard(
      title: 'Informasi Karyawan',
      children: [
        ReceiptCustomizationCheckbox(
          title: 'Nama Kasir',
          value: e.showCashierName,
          onChanged: (v) => _update(_settings.copyWith(
            employee: e.copyWith(showCashierName: v),
          )),
        ),
        ReceiptCustomizationCheckbox(
          title: 'PIC Binatu',
          value: e.showPicBinatu,
          showDivider: false,
          onChanged: (v) => _update(_settings.copyWith(
            employee: e.copyWith(showPicBinatu: v),
          )),
        ),
      ],
    );
  }

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
          onChanged: (v) => _update(_settings.copyWith(showQrCode: v)),
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

  Widget _section10() {
    return ReceiptCustomizationSectionCard(
      title: 'Ukuran Kertas',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s12,
            AppSpacing.s4,
            AppSpacing.s20,
            AppSpacing.s12,
          ),
          child: RadioGroup<ReceiptPaperSize>(
            groupValue: _settings.paperSize,
            onChanged: (value) {
              if (value != null) {
                _update(_settings.copyWith(paperSize: value));
              }
            },
            child: Column(
              children: [
                RadioListTile<ReceiptPaperSize>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('58 mm', style: SettingsTheme.tileTitleStyle),
                  value: ReceiptPaperSize.mm58,
                ),
                RadioListTile<ReceiptPaperSize>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('80 mm', style: SettingsTheme.tileTitleStyle),
                  value: ReceiptPaperSize.mm80,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section11() {
    return ReceiptCustomizationSectionCard(
      title: 'Bahasa Struk',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s12,
            AppSpacing.s4,
            AppSpacing.s20,
            AppSpacing.s12,
          ),
          child: RadioGroup<ReceiptLanguage>(
            groupValue: _settings.language,
            onChanged: (value) {
              if (value != null) {
                _update(_settings.copyWith(language: value));
              }
            },
            child: Column(
              children: [
                RadioListTile<ReceiptLanguage>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Bahasa Indonesia',
                    style: SettingsTheme.tileTitleStyle,
                  ),
                  value: ReceiptLanguage.indonesia,
                ),
                RadioListTile<ReceiptLanguage>(
                  contentPadding: EdgeInsets.zero,
                  title: Text('English', style: SettingsTheme.tileTitleStyle),
                  value: ReceiptLanguage.english,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section12() {
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
          onPressed: _onSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
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
