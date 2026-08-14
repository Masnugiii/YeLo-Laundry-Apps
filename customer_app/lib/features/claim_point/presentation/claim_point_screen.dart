import 'package:flutter/material.dart';

import 'package:yelo_laundry_customer/features/rewards/presentation/yelo_rewards_screen.dart';

/// Legacy route alias. Old "Klaim Point" now opens YeLo Rewards.
class ClaimPointScreen extends StatelessWidget {
  const ClaimPointScreen({super.key});

  @override
  Widget build(BuildContext context) => const YeloRewardsScreen();
}
