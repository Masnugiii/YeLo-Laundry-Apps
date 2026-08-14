import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/pending_order_card.dart';
import 'package:yelo_laundry_customer/features/home/presentation/widgets/pending_payment_card.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class DashboardStatusSlider extends StatefulWidget {
  const DashboardStatusSlider({
    super.key,
    required this.pendingPaymentOrder,
    required this.pendingOrder,
    required this.pendingOrderSteps,
    required this.amountText,
    required this.onPendingPaymentTap,
    required this.onPendingOrderTap,
  });

  final OrderItem? pendingPaymentOrder;
  final OrderItem? pendingOrder;
  final List<LaundryTrackingStep> pendingOrderSteps;
  final String Function(double amount) amountText;
  final VoidCallback? onPendingPaymentTap;
  final VoidCallback onPendingOrderTap;

  @override
  State<DashboardStatusSlider> createState() => _DashboardStatusSliderState();
}

class _DashboardStatusSliderState extends State<DashboardStatusSlider> {
  static const _slideCount = 2;
  static const _defaultCardHeight = 236.0;
  static const _heightBuffer = 8.0;
  static const _indicatorColor = Color(0xFFF4E900);

  late final PageController _pageController;
  int _currentPage = 0;
  double? _paymentCardHeight;
  double? _orderCardHeight;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant DashboardStatusSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pendingPaymentOrder != widget.pendingPaymentOrder ||
        oldWidget.pendingOrder != widget.pendingOrder ||
        oldWidget.pendingOrderSteps != widget.pendingOrderSteps) {
      _paymentCardHeight = null;
      _orderCardHeight = null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _slideCount || index == _currentPage) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  double get _carouselHeight {
    final paymentHeight = _paymentCardHeight ?? _defaultCardHeight;
    final orderHeight = _orderCardHeight ?? _defaultCardHeight;
    return math.max(paymentHeight, orderHeight) + _heightBuffer;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Offstage(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: _MeasureSize(
                            onChange: (size) {
                              final height = size.height;
                              if (height > 0 &&
                                  (_paymentCardHeight == null ||
                                      (height - _paymentCardHeight!).abs() > 0.5)) {
                                setState(() => _paymentCardHeight = height);
                              }
                            },
                            child: _buildPendingPaymentSlide(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: _MeasureSize(
                            onChange: (size) {
                              final height = size.height;
                              if (height > 0 &&
                                  (_orderCardHeight == null ||
                                      (height - _orderCardHeight!).abs() > 0.5)) {
                                setState(() => _orderCardHeight = height);
                              }
                            },
                            child: _buildPendingOrderSlide(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: _carouselHeight,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildCarouselSlide(_buildPendingPaymentSlide()),
                      _buildCarouselSlide(_buildPendingOrderSlide()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            _buildDotIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildCarouselSlide(Widget card) {
    return Align(
      alignment: Alignment.topCenter,
      child: card,
    );
  }

  Widget _buildPendingPaymentSlide() {
    final order = widget.pendingPaymentOrder;
    if (order == null) {
      return const _PendingPaymentEmptyCard();
    }

    return PendingPaymentCard(
      order: order,
      amountText: widget.amountText(order.grandTotal),
      onStatusTap: widget.onPendingPaymentTap ?? () {},
    );
  }

  Widget _buildPendingOrderSlide() {
    final order = widget.pendingOrder;
    if (order == null) {
      return const PendingOrderEmptyCard();
    }

    return PendingOrderCard(
      order: order,
      statusLabel: pendingOrderStatusLabel(order, widget.pendingOrderSteps),
      onDetailTap: widget.onPendingOrderTap,
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_slideCount, (index) {
        final isActive = index == _currentPage;
        return GestureDetector(
          onTap: () => _goToPage(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: isActive ? 8 : 6,
              height: isActive ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _indicatorColor.withValues(alpha: isActive ? 1 : 0.35),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size;
    if (newSize != null && _oldSize != newSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}

class _PendingPaymentEmptyCard extends StatelessWidget {
  const _PendingPaymentEmptyCard();

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupDashboardCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pembayaran yang Tertunda',
            style: _poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.45),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  'Tidak ada pembayaran tertunda',
                  style: _poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Total Pembayaran',
            style: _poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '-',
            style: _poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
