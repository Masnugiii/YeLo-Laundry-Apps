import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';

/// Debug-only override so Dashboard + Klaim Point preview the same membership.
class MembershipDebugPreviewNotifier extends Notifier<MembershipLevel?> {
  @override
  MembershipLevel? build() => null;

  void setPreview(MembershipLevel level) {
    if (!kDebugMode) return;
    state = level;
  }
}

final membershipDebugPreviewProvider =
    NotifierProvider<MembershipDebugPreviewNotifier, MembershipLevel?>(
  MembershipDebugPreviewNotifier.new,
);

/// Single membership level source for all membership cards.
final customerMembershipLevelProvider = Provider<MembershipLevel>((ref) {
  final session = ref.watch(sessionProvider);
  final debugPreview = ref.watch(membershipDebugPreviewProvider);

  if (kDebugMode && debugPreview != null) {
    return debugPreview;
  }

  return session.resolvedMembershipLevel;
});
