import 'package:flutter/material.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/core/membership/membership_card_shell.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';

class MembershipWalletCard extends StatelessWidget {
  const MembershipWalletCard({
    super.key,
    required this.level,
    required this.balanceText,
    required this.balanceVisible,
    required this.onToggleBalanceVisibility,
    this.pointsText,
    this.showPoint = true,
    this.memberSerialNumber,
  });

  final MembershipLevel level;
  final String balanceText;
  final String? pointsText;
  final bool balanceVisible;
  final VoidCallback onToggleBalanceVisibility;
  final bool showPoint;
  final String? memberSerialNumber;

  @override
  Widget build(BuildContext context) {
    final hasSerial =
        memberSerialNumber != null && memberSerialNumber!.trim().isNotEmpty;

    return MembershipCardShell(
      level: level,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MembershipCardHeader(level: level),
          const SizedBox(height: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: showPoint ? 3 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Saldo Yelo',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: MembershipCardStyles.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  onPressed: onToggleBalanceVisibility,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    balanceVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: MembershipCardStyles.textColor,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: MembershipCardPrimaryValue(text: balanceText),
                          ),
                        ],
                      ),
                    ),
                    if (showPoint) ...[
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Yelo Point',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: MembershipCardStyles.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pointsText ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: MembershipCardStyles.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasSerial)
                  MembershipCardSerialFooter(
                    memberSerialNumber: memberSerialNumber!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
