import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/receipt/presentation/widgets/receipt_qr_placeholder.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_payment_theme.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class WalletTopUpQrisScreen extends ConsumerWidget {
  const WalletTopUpQrisScreen({
    super.key,
    required this.confirmation,
  });

  final WalletTopUpConfirmation confirmation;

  void _continueToConfirmation(BuildContext context) {
    context.push('/wallet-top-up/review', extra: confirmation);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentConfigAsync = ref.watch(paymentConfigProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Pembayaran QRIS',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: paymentConfigAsync.when(
        loading: () => const ApiLoadingView(message: 'Memuat data QRIS...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(paymentConfigProvider),
        ),
        data: (config) {
          final qris = config['qris'] as Map<String, dynamic>? ?? const {};
          final isActive = qris['isActive'] as bool? ?? false;
          final qrImageUrl = qris['qrImageUrl'] as String?;
          final instructions = qris['instructions'] as String? ?? '';

          if (!isActive) {
            return const ApiErrorView(
              message:
                  'Konfigurasi QRIS belum tersedia. Hubungi owner/manager.',
            );
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
                    WalletTopUpPaymentCard(
                      child: Column(
                        children: [
                          if (qrImageUrl != null && qrImageUrl.isNotEmpty)
                            Image.network(
                              qrImageUrl,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const ReceiptQrPlaceholder(
                                description: 'QRIS tidak tersedia',
                                fontSize: 12,
                                size: 200,
                              ),
                            )
                          else
                            const ReceiptQrPlaceholder(
                              description: 'QRIS belum dikonfigurasi',
                              fontSize: 12,
                              size: 200,
                            ),
                          const SizedBox(height: AppSpacing.s20),
                          WalletTopUpPaymentInfoRow(
                            label: 'Payment Amount',
                            value: formatRupiah(confirmation.topUpAmount),
                            emphasized: true,
                          ),
                          if (instructions.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.s16),
                            Text(
                              instructions,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.s16),
                          const WalletTopUpPaymentStatusBadge(
                            status: 'Menunggu Pembayaran',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _BottomAction(
                label: 'Saya Sudah Menerima Pembayaran',
                onPressed: () => _continueToConfirmation(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
          onPressed: onPressed,
          style: WalletTopUpPaymentTheme.primaryButtonStyle,
          child: Text(
            label,
            style: WalletTopUpPaymentTheme.primaryButtonTextStyle,
          ),
        ),
      ),
    );
  }
}
