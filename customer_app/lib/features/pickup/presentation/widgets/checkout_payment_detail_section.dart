import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class CheckoutPaymentDetailSection extends StatelessWidget {
  const CheckoutPaymentDetailSection({
    super.key,
    required this.paymentMethodCode,
    required this.totalAmount,
    required this.paymentConfig,
  });

  final String paymentMethodCode;
  final int totalAmount;
  final CustomerPaymentConfig paymentConfig;

  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (paymentMethodCode == CheckoutPaymentMethods.qris) {
      return _buildQrisDetail();
    }
    if (paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
      return _buildTransferDetail();
    }
    return const SizedBox.shrink();
  }

  Widget _buildQrisDetail() {
    final qris = paymentConfig.qris;

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pembayaran QRIS',
            style: _poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s12),
          _summaryRow('Total Pembayaran', _currency.format(totalAmount)),
          const SizedBox(height: AppSpacing.s16),
          if (!qris.isConfigured)
            Text(
              'QRIS belum dikonfigurasi di server. Hubungi outlet untuk pembayaran.',
              style: _poppins(fontSize: 13, color: AppColors.error),
            )
          else ...[
            Center(child: _buildQrWidget(qris)),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Status: Menunggu Pembayaran',
              textAlign: TextAlign.center,
              style: _poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
            if (qris.instructions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                qris.instructions,
                style: _poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildQrWidget(QrisPaymentConfig qris) {
    final imageUrl = qris.qrImageUrl?.trim();
    final payload = qris.qrPayload?.trim();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => _qrErrorPlaceholder(),
        ),
      );
    }

    if (payload != null && payload.isNotEmpty) {
      return QrImageView(
        data: payload,
        size: 220,
        backgroundColor: Colors.white,
      );
    }

    return _qrErrorPlaceholder();
  }

  Widget _qrErrorPlaceholder() {
    return Container(
      width: 220,
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        'QR tidak tersedia',
        style: _poppins(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildTransferDetail() {
    final bank = paymentConfig.bankTransfer;

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Bank',
            style: _poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.s12),
          if (!bank.isConfigured)
            Text(
              'Informasi rekening belum dikonfigurasi di server.',
              style: _poppins(fontSize: 13, color: AppColors.error),
            )
          else ...[
            Text(
              'Transfer ke:',
              style: _poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(bank.bankName, style: _poppins(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.s4),
            Text(
              bank.accountNumber,
              style: _poppins(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              'a.n. ${bank.accountHolder}',
              style: _poppins(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.s12),
            _summaryRow('Total', _currency.format(totalAmount), isTotal: true),
            if (bank.instructions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                bank.instructions,
                style: _poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: _poppins(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.brandBlue : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

bool isPaymentDetailReady(
  String paymentMethodCode,
  CustomerPaymentConfig config,
) {
  if (paymentMethodCode == CheckoutPaymentMethods.qris) {
    return config.qris.isConfigured;
  }
  if (paymentMethodCode == CheckoutPaymentMethods.bankTransfer) {
    return config.bankTransfer.isConfigured;
  }
  return true;
}
