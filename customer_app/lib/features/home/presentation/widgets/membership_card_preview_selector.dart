import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/core/membership/membership_level.dart';

/// Debug-only selector to preview membership card themes.
/// Remove this widget after design approval.
class MembershipCardPreviewSelector extends StatelessWidget {
  const MembershipCardPreviewSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MembershipLevel selected;
  final ValueChanged<MembershipLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview Membership (Card & Badge)',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<MembershipLevel>(
            segments: [
              for (final level in MembershipLevel.values)
                ButtonSegment<MembershipLevel>(
                  value: level,
                  label: Text(
                    level.label[0] + level.label.substring(1).toLowerCase(),
                  ),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) onChanged(selection.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white.withValues(alpha: 0.22);
                }
                return Colors.white.withValues(alpha: 0.08);
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              side: WidgetStateProperty.all(
                BorderSide(color: Colors.white.withValues(alpha: 0.25)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
