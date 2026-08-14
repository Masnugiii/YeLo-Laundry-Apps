import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/core/navigation/navigation_utils.dart';

/// Standard Internal App AppBar with consistent back behavior.
class ErpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ErpAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = AppColors.onPrimary,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = canNavigateBack(context);

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      automaticallyImplyLeading: showBackButton && canPop,
      leading: showBackButton && canPop
          ? BackButton(
              color: foregroundColor,
              onPressed: onBack ?? () => navigateBack(context),
            )
          : null,
      iconTheme: IconThemeData(color: foregroundColor),
      actionsIconTheme: IconThemeData(color: foregroundColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      ),
      actions: actions,
    );
  }
}
