import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/core/membership/membership_level.dart';

class MembershipBadge extends StatelessWidget {
  const MembershipBadge({
    super.key,
    required this.level,
    this.showLabel = true,
  });

  final MembershipLevel level;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 5 : 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            level.accentColor,
            Color.lerp(level.accentColor, level.borderColor, 0.35)!,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: level.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level.icon,
            size: 10,
            color: level.textColor,
          ),
          if (showLabel) ...[
            const SizedBox(width: 2),
            Text(
              level.label,
              style: GoogleFonts.poppins(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0.2,
                color: level.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileAvatarWithMembershipBadge extends StatelessWidget {
  const ProfileAvatarWithMembershipBadge({
    super.key,
    required this.level,
    required this.avatar,
    this.radius = 20,
    this.onTap,
  });

  final MembershipLevel level;
  final Widget avatar;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size + 6,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            avatar,
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: MembershipBadge(level: level),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
