import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/auth/presentation/widgets/auth_screen_styles.dart';

class DevPreviewEntryButton extends ConsumerWidget {
  const DevPreviewEntryButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!DevPreviewGate.isAvailable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: compact ? 8 : 16),
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(authProvider.notifier).enterDevPreview();
          context.go('/home');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AuthScreenStyles.peopleHighlightColor,
          side: const BorderSide(color: AuthScreenStyles.peopleHighlightColor),
          minimumSize: Size.fromHeight(compact ? 44 : 48),
        ),
        icon: const Icon(Icons.developer_mode, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            compact ? 'Preview Dashboard (Dev)' : 'Buka Dashboard Preview (Dev)',
            maxLines: 1,
            style: AuthScreenStyles.poppins(
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
