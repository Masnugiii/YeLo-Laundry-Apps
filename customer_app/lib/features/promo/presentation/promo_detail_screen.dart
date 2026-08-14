import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';
import 'package:yelo_laundry_customer/features/promo/providers/promo_providers.dart';



class PromoDetailScreen extends ConsumerWidget {
  const PromoDetailScreen({
    super.key,
    required this.promoId,
    this.initialPromo,
  });

  final String promoId;
  final CustomerPromo? initialPromo;

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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s8,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Detail Promo',
                  style: _poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: _poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            value,
            style: _poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promo = initialPromo;

    if (promo == null || promo.id != promoId) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: Text(
                  'Promo tidak ditemukan.',
                  style: _poppins(fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final period = promo.expiresAt == null
        ? null
        : 'Berlaku sampai ${DateFormat('d MMMM yyyy', 'id_ID').format(promo.expiresAt!.toLocal())}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s12,
                AppSpacing.s16,
                AppSpacing.s16,
              ),
              children: [
                PickupDashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (promo.bannerUrl != null &&
                          promo.bannerUrl!.trim().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            promo.bannerUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      if (promo.bannerUrl != null &&
                          promo.bannerUrl!.trim().isNotEmpty)
                        const SizedBox(height: AppSpacing.s12),
                      Text(
                        promo.title,
                        style: _poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (promo.badgePercentLabel != null) ...[
                        const SizedBox(height: AppSpacing.s8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            promo.badgePercentLabel!,
                            style: _poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandBlue,
                            ),
                          ),
                        ),
                      ],
                      if (promo.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s12),
                        _infoBlock('Deskripsi', promo.description),
                      ],
                      if (promo.minTransaction != null)
                        _infoBlock(
                          'Minimum Transaksi',
                          _currency.format(promo.minTransaction),
                        ),
                      if (period != null) _infoBlock('Periode Promo', period),
                      if (promo.voucherCode != null &&
                          promo.voucherCode!.trim().isNotEmpty)
                        _infoBlock('Kode Voucher', promo.voucherCode!),
                      if (promo.terms != null && promo.terms!.trim().isNotEmpty)
                        _infoBlock('Syarat & Ketentuan', promo.terms!),
                      _infoBlock(
                        'Status',
                        promo.isUsable ? 'Promo aktif' : 'Belum dapat digunakan',
                      ),
                      if (!promo.isUsable &&
                          promo.unusableReason != null &&
                          promo.unusableReason!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          promo.unusableReason!,
                          style: _poppins(
                            fontSize: 13,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      if (promo.voucherCode != null &&
                          promo.voucherCode!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s8),
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: promo.voucherCode!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode voucher disalin'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('Salin Kode'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                if (promo.isUsable)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ref.read(selectedPromoProvider.notifier).select(promo);
                        context.go('/pickup');
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.brandBlue,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Gunakan Promo',
                        style: _poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
