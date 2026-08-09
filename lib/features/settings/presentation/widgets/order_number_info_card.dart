import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';

class OrderNumberInfoCard extends StatelessWidget {
  const OrderNumberInfoCard({
    super.key,
    this.readOnly = false,
  });

  final bool readOnly;

  static const _backgroundColor = Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              readOnly
                  ? 'Nomor antrian berikutnya akan otomatis bertambah dari nomor saat ini.\n\n'
                      'Hubungi Owner jika penomoran perlu diubah.'
                  : 'Pengaturan ini hanya digunakan sebagai nomor awal.\n\n'
                      'Seluruh order berikutnya akan bertambah otomatis.\n\n'
                      'Riwayat order lama tidak akan dibuat ulang.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
