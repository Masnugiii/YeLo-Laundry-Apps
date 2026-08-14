import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';

/// Shared AppBar styling for Laci Laundry feature screens.
class LaciFeatureAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LaciFeatureAppBar({
    super.key,
    required this.title,
    this.icon = Icons.inventory_2_outlined,
  });

  final String title;
  final IconData icon;

  static const double titleIconSize = 24;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      iconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: titleIconSize,
      ),
      title: Row(
        children: [
          Icon(
            icon,
            color: AppColors.onPrimary,
            size: titleIconSize,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
