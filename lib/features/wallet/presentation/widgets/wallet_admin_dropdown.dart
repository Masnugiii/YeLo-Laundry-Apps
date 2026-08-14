import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';

class WalletAdminDropdown extends StatelessWidget {
  const WalletAdminDropdown({
    super.key,
    required this.selectedAdmin,
    required this.onChanged,
    required this.admins,
  });

  final WalletAdmin selectedAdmin;
  final ValueChanged<WalletAdmin> onChanged;
  final List<WalletAdmin> admins;

  static const _labelColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    if (admins.length <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin yang Bertanggung Jawab',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              selectedAdmin.name,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
    }

    return DropdownMenu<WalletAdmin>(
      key: ValueKey(selectedAdmin.id),
      width: MediaQuery.sizeOf(context).width - 40,
      initialSelection: selectedAdmin,
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      label: Text(
        'Admin yang Bertanggung Jawab',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _labelColor,
        ),
      ),
      dropdownMenuEntries: [
        for (final admin in admins)
          DropdownMenuEntry(
            value: admin,
            label: admin.name,
          ),
      ],
      onSelected: (admin) {
        if (admin != null) {
          onChanged(admin);
        }
      },
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
