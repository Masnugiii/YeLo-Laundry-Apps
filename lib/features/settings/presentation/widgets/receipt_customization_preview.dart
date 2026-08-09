import 'package:flutter/material.dart';

import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/data/dummy_laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/models/laundry_receipt.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/receipt_theme.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_divider.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_qr_placeholder.dart';
import 'package:yelo_laundry_erp/features/settings/data/dummy_laundry_profile.dart';
import 'package:yelo_laundry_erp/features/settings/models/laundry_profile.dart';
import 'package:yelo_laundry_erp/features/settings/models/receipt_customization_settings.dart';

class ReceiptCustomizationPreview extends StatelessWidget {
  const ReceiptCustomizationPreview({
    super.key,
    required this.settings,
  });

  final ReceiptCustomizationSettings settings;

  static const _previewPickupSchedule = '09 Agustus 2026, 08:00 WIB';
  static const _previewDeliverySchedule = '-';
  static const _previewPicBinatu = 'Budi Santoso';

  LaundryReceipt get _receipt => dummyLaundryReceipt;

  bool get _isEnglish => settings.language == ReceiptLanguage.english;

  String _label(String id, String en, String idLang) => _isEnglish ? en : idLang;

  double get _previewWidth => settings.paperSize == ReceiptPaperSize.mm58 ? 180.0 : 240.0;

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    final profile = getLaundryProfile();
    const baseFont = 7.0;
    const titleFont = 8.5;

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
              Center(
                child: Image.asset(
                  profile.logoAsset,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (_hasBusinessText) const ReceiptDivider(),
            if (settings.business.showName)
              Center(
                child: Text(
                  profile.name,
                  style: ReceiptTheme.titleText(titleFont),
                  textAlign: TextAlign.center,
                ),
              ),
            if (settings.business.showAddress) ...[
              const SizedBox(height: 2),
              Center(
                child: Text(
                  profile.fullAddress,
                  textAlign: TextAlign.center,
                  style: ReceiptTheme.centerText(baseFont),
                ),
              ),
            ],
            if (settings.business.showWhatsapp ||
                settings.business.showInstagram ||
                settings.business.showWebsite) ...[
              const SizedBox(height: 2),
              Center(
                child: Text(
                  _businessContactLines(profile),
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
              if (settings.order.showOrderDate) ...[
                const ReceiptDivider(),
                _row(
                  _label('date', 'Order Date', 'Tanggal Order'),
                  '${receipt.orderDate}\n${receipt.orderTime}',
                  baseFont,
                  multiline: true,
                ),
              ],
              if (settings.order.showEstimatedFinish) ...[
                const ReceiptDivider(),
                _row(
                  _label('finish', 'Estimated Finish', 'Estimasi Selesai'),
                  '${receipt.estimatedFinishDate}\n${receipt.estimatedFinishTime}',
                  baseFont,
                  multiline: true,
                ),
              ],
            ],
            if (_hasCustomerSection) ...[
              const ReceiptDivider(),
              if (settings.customer.showCustomerName)
                _row(
                  _label('cust', 'Customer Name', 'Nama Customer'),
                  receipt.customerName,
                  baseFont,
                ),
              if (settings.customer.showPhone) ...[
                const ReceiptDivider(),
                _row(
                  _label('phone', 'Phone', 'Nomor HP'),
                  receipt.customerPhone,
                  baseFont,
                ),
              ],
            ],
            if (settings.service.hasServiceTable) ...[
              const ReceiptDivider(),
              _serviceTable(baseFont),
            ],
            if (settings.service.showSubtotal) ...[
              const ReceiptDivider(),
              _row(
                _label('sub', 'Subtotal', 'Subtotal'),
                formatRupiah(receipt.subtotal),
                baseFont,
              ),
            ],
            if (settings.service.showDiscount) ...[
              const ReceiptDivider(),
              _row(
                _label('disc', 'Discount', 'Diskon'),
                formatRupiah(receipt.discount),
                baseFont,
              ),
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
            if (_hasPaymentSection) ...[
              const ReceiptDivider(),
              if (settings.payment.showPaymentMethod)
                _row(
                  _label('pm', 'Payment Method', 'Metode Pembayaran'),
                  receipt.paymentMethod,
                  baseFont,
                ),
              if (settings.payment.showPaymentStatus) ...[
                const ReceiptDivider(),
                _row(
                  _label('ps', 'Payment Status', 'Status Pembayaran'),
                  receipt.paymentStatus,
                  baseFont,
                ),
              ],
            ],
            if (_hasPickupDeliverySection) ...[
              const ReceiptDivider(),
              if (settings.pickupDelivery.showPickup)
                _row(
                  'Pickup',
                  receipt.pickupLabel,
                  baseFont,
                ),
              if (settings.pickupDelivery.showDelivery) ...[
                const ReceiptDivider(),
                _row('Delivery', receipt.deliveryLabel, baseFont),
              ],
              if (settings.pickupDelivery.showPickupSchedule) ...[
                const ReceiptDivider(),
                _row(
                  _label('psch', 'Pickup Schedule', 'Jadwal Pickup'),
                  _previewPickupSchedule,
                  baseFont,
                ),
              ],
              if (settings.pickupDelivery.showDeliverySchedule) ...[
                const ReceiptDivider(),
                _row(
                  _label('dsch', 'Delivery Schedule', 'Jadwal Delivery'),
                  _previewDeliverySchedule,
                  baseFont,
                ),
              ],
            ],
            if (_hasEmployeeSection) ...[
              const ReceiptDivider(),
              if (settings.employee.showCashierName)
                _row(
                  _label('kasir', 'Cashier', 'Nama Kasir'),
                  receipt.cashierName,
                  baseFont,
                ),
              if (settings.employee.showPicBinatu) ...[
                const ReceiptDivider(),
                _row(
                  _label('binatu', 'Laundry PIC', 'PIC Binatu'),
                  _previewPicBinatu,
                  baseFont,
                ),
              ],
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
      settings.business.showWhatsapp ||
      settings.business.showInstagram ||
      settings.business.showWebsite;

  bool get _hasOrderSection =>
      settings.order.showOrderNumber ||
      settings.order.showQueueNumber ||
      settings.order.showOrderDate ||
      settings.order.showEstimatedFinish;

  bool get _hasCustomerSection =>
      settings.customer.showCustomerName || settings.customer.showPhone;

  bool get _hasPaymentSection =>
      settings.payment.showPaymentMethod || settings.payment.showPaymentStatus;

  bool get _hasPickupDeliverySection =>
      settings.pickupDelivery.showPickup ||
      settings.pickupDelivery.showDelivery ||
      settings.pickupDelivery.showPickupSchedule ||
      settings.pickupDelivery.showDeliverySchedule;

  bool get _hasEmployeeSection =>
      settings.employee.showCashierName || settings.employee.showPicBinatu;

  String _businessContactLines(LaundryProfile profile) {
    final lines = <String>[];
    if (settings.business.showWhatsapp) {
      lines.add('WA : ${profile.whatsapp}');
    }
    if (settings.business.showInstagram) {
      lines.add('Instagram : ${profile.instagram}');
    }
    if (settings.business.showWebsite) {
      lines.add('Website : ${profile.website}');
    }
    return lines.join('\n');
  }

  Widget _row(
    String label,
    String value,
    double fontSize, {
    bool multiline = false,
    bool emphasized = false,
  }) {
    final style = ReceiptTheme.baseText(
      fontSize,
      weight: emphasized ? FontWeight.w700 : FontWeight.w500,
    );

    if (multiline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: style),
          Text(value, style: style.copyWith(fontWeight: FontWeight.w600)),
        ],
      );
    }

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

  Widget _serviceTable(double fontSize) {
    final headerStyle = ReceiptTheme.baseText(fontSize, weight: FontWeight.w700);
    final cellStyle = ReceiptTheme.baseText(fontSize);

    return Column(
      children: [
        Row(
          children: [
            if (settings.service.showServiceName)
              Expanded(
                flex: 4,
                child: Text(
                  _label('svc', 'Service', 'Layanan'),
                  style: headerStyle,
                ),
              ),
            if (settings.service.showWeight)
              Expanded(
                flex: 2,
                child: Text(
                  _label('wgt', 'Weight', 'Berat'),
                  style: headerStyle,
                ),
              ),
            if (settings.service.showPrice)
              Expanded(
                flex: 3,
                child: Text(
                  _label('prc', 'Price', 'Harga'),
                  textAlign: TextAlign.end,
                  style: headerStyle,
                ),
              ),
          ],
        ),
        const ReceiptDivider(),
        for (var i = 0; i < _receipt.lineItems.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (settings.service.showServiceName)
                Expanded(
                  flex: 4,
                  child: Text(_receipt.lineItems[i].serviceName, style: cellStyle),
                ),
              if (settings.service.showWeight)
                Expanded(
                  flex: 2,
                  child: Text(_receipt.lineItems[i].weight, style: cellStyle),
                ),
              if (settings.service.showPrice)
                Expanded(
                  flex: 3,
                  child: Text(
                    formatRupiah(_receipt.lineItems[i].price),
                    textAlign: TextAlign.end,
                    style: cellStyle,
                  ),
                ),
            ],
          ),
          if (i < _receipt.lineItems.length - 1) const ReceiptDivider(),
        ],
      ],
    );
  }
}
