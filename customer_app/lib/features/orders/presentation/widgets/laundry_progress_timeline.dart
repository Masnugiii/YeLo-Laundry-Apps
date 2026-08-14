import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';


const _inactiveLine = Color(0xFFE5E7EB);
const _inactiveCircle = Color(0xFFD1D5DB);
const _labelInactive = Color(0xFF9CA3AF);

/// Logical timeline steps (6) — basket animation uses all indices.
const laundryTimelineLogicalStepCount = 6;

/// Labels rendered below timeline circles (index 4 omitted — shown on card).
const Map<int, String> laundryTimelineCircleLabels = {
  0: 'Diterima',
  1: 'Diproses',
  2: 'Dicuci',
  3: 'Disetrika',
  5: 'Selesai',
};

/// Circle indices visible on the timeline track.
const List<int> laundryTimelineVisibleCircleIndices = [0, 1, 2, 3, 5];

/// Maps backend tracking step keys to logical UI timeline index (0–5).
const Map<String, int> laundryBackendKeyToUiIndex = {
  'receiving': 0,
  'received': 0,
  'washing': 1,
  'drying': 2,
  'ironing': 3,
  'quality_check': 4,
  'ready_pickup': 4,
  'ready': 4,
  'completed': 5,
};

class LaundryTimelineUiState {
  const LaundryTimelineUiState({
    required this.currentIndex,
    required this.activeThroughIndex,
  });

  final int currentIndex;
  final int activeThroughIndex;

  bool get isSiapDiambilPhase => currentIndex == 4;
}

LaundryTimelineUiState resolveLaundryTimelineUiState(
  List<LaundryTrackingStep> steps,
) {
  if (steps.isEmpty) {
    return const LaundryTimelineUiState(currentIndex: 0, activeThroughIndex: 0);
  }

  final backendCurrent = steps.indexWhere(
    (step) => step.status == 'current' || step.status == 'in_progress',
  );

  int currentIndex;
  if (backendCurrent >= 0) {
    currentIndex = laundryBackendKeyToUiIndex[steps[backendCurrent].key] ?? 0;
  } else if (steps.every((step) => step.status == 'completed')) {
    currentIndex = laundryTimelineLogicalStepCount - 1;
  } else {
    final firstPending = steps.indexWhere((step) => step.status == 'pending');
    if (firstPending > 0) {
      currentIndex =
          laundryBackendKeyToUiIndex[steps[firstPending - 1].key] ?? 0;
    } else {
      currentIndex = 0;
    }
  }

  final clamped = currentIndex.clamp(0, laundryTimelineLogicalStepCount - 1);
  return LaundryTimelineUiState(
    currentIndex: clamped,
    activeThroughIndex: clamped,
  );
}

/// Horizontal laundry progress timeline driven by [LaundryTrackingStep] from API.
///
/// Basket is placed immediately on initial load. Animation runs only when the
/// resolved UI step index changes after a data update (e.g. pull-to-refresh).
class LaundryProgressTimeline extends StatefulWidget {
  const LaundryProgressTimeline({
    super.key,
    required this.steps,
    this.compact = false,
  });

  final List<LaundryTrackingStep> steps;
  final bool compact;

  @override
  State<LaundryProgressTimeline> createState() => _LaundryProgressTimelineState();
}

class _LaundryProgressTimelineState extends State<LaundryProgressTimeline>
    with SingleTickerProviderStateMixin {
  double get _circleSize => widget.compact ? 12.0 : 14.0;
  double get _timelineRowHeight => widget.compact ? 28.0 : 36.0;
  double get _labelAreaHeight => widget.compact ? 30.0 : 44.0;
  double get _basketSize => widget.compact ? 16.0 : 20.0;
  double get _basketTopPadding => widget.compact ? 14.0 : 22.0;
  double get _labelTopGap => widget.compact ? 6.0 : 10.0;
  double get _minStepSpacing => widget.compact ? 52.0 : 76.0;
  double get _horizontalEdgePadding => widget.compact ? 12.0 : 24.0;
  double get _labelSlotWidth => widget.compact ? 64.0 : 78.0;
  double get _labelFontSize => widget.compact ? 9.0 : 10.0;

  late AnimationController _controller;
  late Animation<double> _progress;

  int _fromIndex = 0;
  int _toIndex = 0;
  int _resolvedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _snapToCurrentIndex(widget.steps);
  }

  @override
  void didUpdateWidget(LaundryProgressTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextIndex = resolveLaundryTimelineUiState(widget.steps).currentIndex;
    if (nextIndex == _resolvedIndex) return;

    _fromIndex = _resolvedIndex;
    _toIndex = nextIndex;
    _resolvedIndex = nextIndex;
    _controller
      ..reset()
      ..forward();
  }

  void _snapToCurrentIndex(List<LaundryTrackingStep> steps) {
    _resolvedIndex = resolveLaundryTimelineUiState(steps).currentIndex;
    _fromIndex = _resolvedIndex;
    _toIndex = _resolvedIndex;
    _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _minTimelineWidth() {
    return _horizontalEdgePadding * 2 +
        _circleSize +
        _minStepSpacing * (laundryTimelineLogicalStepCount - 1);
  }

  List<double> _circlePositions(double timelineWidth) {
    final stepSpacing = (timelineWidth -
            _horizontalEdgePadding * 2 -
            _circleSize) /
        (laundryTimelineLogicalStepCount - 1);
    final startX = _horizontalEdgePadding + _circleSize / 2;
    return List.generate(
      laundryTimelineLogicalStepCount,
      (index) => startX + index * stepSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final uiState = resolveLaundryTimelineUiState(widget.steps);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final minWidth = _minTimelineWidth();
        final timelineWidth = screenWidth >= minWidth ? screenWidth : minWidth;
        final needsScroll = timelineWidth > screenWidth;
        final positions = _circlePositions(timelineWidth);
        final labelTop = _basketTopPadding + _timelineRowHeight + _labelTopGap;

        final timeline = SizedBox(
          width: timelineWidth,
          height: _basketTopPadding + _timelineRowHeight + _labelAreaHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: _basketTopPadding,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(timelineWidth, _timelineRowHeight),
                  painter: _TimelineLinePainter(
                    positions: positions,
                    activeUntilIndex: uiState.activeThroughIndex,
                    circleRadius: _circleSize / 2,
                    y: _timelineRowHeight / 2,
                  ),
                ),
              ),
              for (final i in laundryTimelineVisibleCircleIndices)
                Positioned(
                  left: positions[i] - _circleSize / 2,
                  top: _basketTopPadding + _timelineRowHeight / 2 - _circleSize / 2,
                  child: _TimelineCircle(
                    size: _circleSize,
                    isActive: i <= uiState.activeThroughIndex,
                    isCurrent: i == _resolvedIndex,
                  ),
                ),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  final fromX = positions[
                      _fromIndex.clamp(0, laundryTimelineLogicalStepCount - 1)];
                  final toX = positions[
                      _toIndex.clamp(0, laundryTimelineLogicalStepCount - 1)];
                  final x = fromX + (toX - fromX) * _progress.value;
                  return Positioned(
                    left: (x - _basketSize / 2)
                        .clamp(0.0, timelineWidth - _basketSize),
                    top: _basketTopPadding +
                        _timelineRowHeight / 2 -
                        _circleSize / 2 -
                        _basketSize -
                        2,
                    child: child!,
                  );
                },
                child: Container(
                  width: _basketSize,
                  height: _basketSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_laundry_service,
                    size: widget.compact ? 10 : 12,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              for (final entry in laundryTimelineCircleLabels.entries)
                Positioned(
                  left: (positions[entry.key] - _labelSlotWidth / 2).clamp(
                    0.0,
                    timelineWidth - _labelSlotWidth,
                  ),
                  top: labelTop,
                  width: _labelSlotWidth,
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      fontSize: _labelFontSize,
                      fontWeight:
                          entry.key == _resolvedIndex ? FontWeight.w600 : FontWeight.w500,
                      height: 1.2,
                      color: entry.key <= uiState.activeThroughIndex
                          ? AppColors.textPrimary
                          : _labelInactive,
                    ),
                  ),
                ),
            ],
          ),
        );

        if (!needsScroll) return timeline;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: timeline,
        );
      },
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  const _TimelineCircle({
    required this.size,
    required this.isActive,
    required this.isCurrent,
  });

  final double size;
  final bool isActive;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.accent : _inactiveCircle,
        border: isCurrent
            ? Border.all(color: AppColors.brandBlue, width: 2)
            : null,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
    );
  }
}

class _TimelineLinePainter extends CustomPainter {
  _TimelineLinePainter({
    required this.positions,
    required this.activeUntilIndex,
    required this.circleRadius,
    required this.y,
  });

  final List<double> positions;
  final int activeUntilIndex;
  final double circleRadius;
  final double y;

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final inactivePaint = Paint()
      ..color = _inactiveLine
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < positions.length - 1; i++) {
      final startX = positions[i] + circleRadius;
      final endX = positions[i + 1] - circleRadius;
      final paint = i < activeUntilIndex ? activePaint : inactivePaint;
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimelineLinePainter oldDelegate) {
    return oldDelegate.activeUntilIndex != activeUntilIndex ||
        oldDelegate.positions != positions;
  }
}
