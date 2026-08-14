import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/utils/currency_formatter.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_top_up_confirmation.dart';
import 'package:yelo_laundry_erp/features/wallet/presentation/widgets/wallet_top_up_payment_theme.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';

class WalletTopUpTransferScreen extends ConsumerWidget {
  const WalletTopUpTransferScreen({
    super.key,
    required this.confirmation,
  });

  final WalletTopUpConfirmation confirmation;

  void _copyAccountNumber(BuildContext context, String accountNumber) {
    if (accountNumber.isEmpty) return;
    Clipboard.setData(ClipboardData(text: accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Nomor rekening berhasil disalin.',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

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
          'Transfer Bank',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: paymentConfigAsync.when(
        loading: () => const ApiLoadingView(message: 'Memuat data pembayaran...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: () => ref.invalidate(paymentConfigProvider),
        ),
        data: (config) {
          final bankTransfer =
              config['bankTransfer'] as Map<String, dynamic>? ?? const {};
          final bankName = bankTransfer['bankName'] as String? ?? '';
          final accountNumber = bankTransfer['accountNumber'] as String? ?? '';
          final accountHolder = bankTransfer['accountHolder'] as String? ?? '';
          final isActive = bankTransfer['isActive'] as bool? ?? false;

          if (!isActive ||
              (bankName.isEmpty &&
                  accountNumber.isEmpty &&
                  accountHolder.isEmpty)) {
            return const ApiErrorView(
              message:
                  'Konfigurasi transfer bank belum tersedia. Hubungi owner/manager.',
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
                          WalletTopUpPaymentInfoRow(
                            label: 'Bank Name',
                            value: bankName.isNotEmpty ? bankName : '—',
                          ),
                          const WalletTopUpPaymentDivider(),
                          WalletTopUpPaymentInfoRow(
                            label: 'Account Number',
                            value:
                                accountNumber.isNotEmpty ? accountNumber : '—',
                            emphasized: true,
                          ),
                          const WalletTopUpPaymentDivider(),
                          WalletTopUpPaymentInfoRow(
                            label: 'Account Holder',
                            value:
                                accountHolder.isNotEmpty ? accountHolder : '—',
                          ),
                          const WalletTopUpPaymentDivider(),
                          WalletTopUpPaymentInfoRow(
                            label: 'Payment Amount',
                            value: formatRupiah(confirmation.topUpAmount),
                            emphasized: true,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      onPressed: accountNumber.isEmpty
                          ? null
                          : () => _copyAccountNumber(context, accountNumber),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Salin Nomor Rekening',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    FilledButton(
                      onPressed: () => _continueToConfirmation(context),
                      style: WalletTopUpPaymentTheme.primaryButtonStyle,
                      child: Text(
                        'Saya Sudah Menerima Pembayaran',
                        style: WalletTopUpPaymentTheme.primaryButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
