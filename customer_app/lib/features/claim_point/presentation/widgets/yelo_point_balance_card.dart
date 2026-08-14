import 'package:flutter/material.dart';

import 'package:yelo_laundry_customer/core/membership/membership_card_shell.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';

class YeloPointBalanceCard extends StatelessWidget {
  const YeloPointBalanceCard({
    super.key,
    required this.level,
    required this.pointsLabel,
    this.loading = false,
    this.memberSerialNumber,
  });

  final MembershipLevel level;
  final String pointsLabel;
  final bool loading;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: const Alignment(-1, 0.2),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: MembershipCardStyles.textColor,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              pointsLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MembershipCardPrimaryValue.textStyle(),
                            ),
                          ),
                  ),
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
