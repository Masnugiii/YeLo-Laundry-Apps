import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/data/receipt_preview_sample.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/company_receipt_header.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_divider.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_qr_placeholder.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_customization_settings.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_settings_config.dart';

class ReceiptCustomizationPreview extends StatelessWidget {
  const ReceiptCustomizationPreview({
    super.key,
    required this.settings,
    required this.receiptConfig,
  });

  final ReceiptCustomizationSettings settings;
  final ReceiptSettingsConfig receiptConfig;

  static const _previewPickupSchedule = '09 Agustus 2026, 08:00 WIB';
  static const _previewDeliverySchedule = '-';
  static const _previewPicBinatu = 'PIC Binatu';

  LaundryReceipt get _receipt => ReceiptPreviewSample.receipt;

  bool get _isEnglish => settings.language == ReceiptLanguage.english;

  String _label(String id, String en, String idLang) => _isEnglish ? en : idLang;

  double get _previewWidth =>
      settings.paperSize == ReceiptPaperSize.mm58 ? 180.0 : 240.0;

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    const baseFont = 7.0;

    return Center(
      child: Container(
        width: _previewWidth,
        decoration: BoxDecoration(
          color: ReceiptTheme.backgroundColor,
          border: Border.all(color: ReceiptTheme.dividerColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (settings.business.showLogo) ...[
              CompanyReceiptHeader(
                config: receiptConfig,
                logoHeight: 28,
                titleFontSize: 8.5,
                baseFontSize: baseFont,
                showLogo: true,
                spacing: 4,
              ),
            ],
            if (_hasBusinessText) const ReceiptDivider(),
            if (settings.business.showName)
              Center(
                child: Text(
                  receiptConfig.companyName,
                  style: ReceiptTheme.titleText(8.5),
                  textAlign: TextAlign.center,
                ),
              ),
            if (settings.business.showAddress &&
                receiptConfig.companyAddress?.isNotEmpty == true) ...[
              const SizedBox(height: 2),
              Center(
                child: Text(
                  receiptConfig.companyAddress!,
                  textAlign: TextAlign.center,
                  style: ReceiptTheme.centerText(baseFont),
                ),
              ),
            ],
            if (settings.business.showWhatsapp &&
                receiptConfig.companyPhone?.isNotEmpty == true) ...[
              const SizedBox(height: 2),
              Center(
                child: Text(
                  'WA : ${receiptConfig.companyPhone}',
                  textAlign: TextAlign.center,
                  style: ReceiptTheme.centerText(baseFont),
                ),
              ),
            ],
            if (_hasOrderSection) ...[
              const ReceiptDivider(),
              if (settings.order.showOrderNumber)
                _row(
                  _label('order', 'Order Number', 'Nomor Order'),
                  receipt.orderNumber,
                  baseFont,
                ),
              if (settings.order.showQueueNumber) ...[
                const ReceiptDivider(),
                _row(
                  _label('queue', 'Queue Number', 'Nomor Antrian'),
                  receipt.queueNumber,
                  baseFont,
                ),
              ],
            ],
            if (settings.service.showGrandTotal) ...[
              const ReceiptDivider(),
              _row(
                _label('total', 'Grand Total', 'Grand Total'),
                formatRupiah(receipt.grandTotal),
                baseFont,
                emphasized: true,
              ),
            ],
            if (settings.showQrCode) ...[
              const ReceiptDivider(),
              Center(
                child: ReceiptQrPlaceholder(
                  description: receipt.qrDescription,
                  fontSize: baseFont,
                  size: 48,
                ),
              ),
            ],
            if (settings.receiptNote.trim().isNotEmpty) ...[
              const ReceiptDivider(),
              Text(
                settings.receiptNote,
                textAlign: TextAlign.center,
                style: ReceiptTheme.baseText(baseFont - 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasBusinessText =>
      settings.business.showName ||
      settings.business.showAddress ||
      settings.business.showWhatsapp;

  bool get _hasOrderSection =>
      settings.order.showOrderNumber || settings.order.showQueueNumber;

  Widget _row(
    String label,
    String value,
    double fontSize, {
    bool emphasized = false,
  }) {
    final style = ReceiptTheme.baseText(
      fontSize,
      weight: emphasized ? FontWeight.w700 : FontWeight.w500,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: style.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
