import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/core/membership/member_serial_number.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/core/membership/membership_theme.dart';

/// Shared visual shell for membership cards (Dashboard + Klaim Point).
abstract final class MembershipCardStyles {
  static const aspectRatio = 2.15;
  static const borderRadius = 16.0;
  static const textColor = Color(0xFF000000);
  static const contentPadding = EdgeInsets.fromLTRB(
    AppSpacing.s12,
    AppSpacing.s12,
    AppSpacing.s12,
    AppSpacing.s12,
  );

  static TextStyle poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textColor,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

/// Primary numeric value on membership cards (e.g. saldo / total point).
class MembershipCardPrimaryValue extends StatelessWidget {
  const MembershipCardPrimaryValue({super.key, required this.text});

  final String text;

  static TextStyle textStyle() {
    return MembershipCardStyles.poppins(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle(),
    );
  }
}

class MembershipCardShell extends StatelessWidget {
  const MembershipCardShell({
    super.key,
    required this.level,
    required this.child,
  });

  final MembershipLevel level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = level.cardTheme;

    return AspectRatio(
      aspectRatio: MembershipCardStyles.aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(MembershipCardStyles.borderRadius),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(MembershipCardStyles.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: theme.gradientColors,
                  ),
                  border: Border.all(
                    color: theme.borderColor.withValues(alpha: 0.7),
                    width: 1,
                  ),
                ),
              ),
              Positioned(
                top: -24,
                right: -14,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.glossColor.withValues(alpha: 0.38),
                        theme.glossColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.highlightColor.withValues(alpha: 0),
                        theme.highlightColor.withValues(alpha: 0.5),
                        theme.highlightColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: MembershipCardStyles.contentPadding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MembershipCardHeader extends StatelessWidget {
  const MembershipCardHeader({super.key, required this.level});

  final MembershipLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = level.cardTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YELO LAUNDRY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MembershipCardStyles.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${level.label} MEMBER',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MembershipCardStyles.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Icon(
          level.icon,
          size: 20,
          color: theme.highlightColor,
        ),
      ],
    );
  }
}

class MembershipCardSerialFooter extends StatelessWidget {
  const MembershipCardSerialFooter({
    super.key,
    required this.memberSerialNumber,
  });

  final String memberSerialNumber;

  @override
  Widget build(BuildContext context) {
    final serialLabel = MemberSerialNumber.formatForCard(memberSerialNumber);
    final serialQrPayload = MemberSerialNumber.qrPayload(memberSerialNumber);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            serialLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MembershipCardStyles.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        QrImageView(
          data: serialQrPayload,
          size: 38,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: MembershipCardStyles.textColor,
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: MembershipCardStyles.textColor,
          ),
        ),
      ],
    );
  }
}
