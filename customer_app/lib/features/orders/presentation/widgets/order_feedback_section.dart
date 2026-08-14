import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_feedback_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class OrderFeedbackSection extends StatefulWidget {
  const OrderFeedbackSection({
    super.key,
    required this.orderId,
    required this.repository,
  });

  final String orderId;
  final OrderFeedbackRepository repository;

  @override
  State<OrderFeedbackSection> createState() => _OrderFeedbackSectionState();
}

class _OrderFeedbackSectionState extends State<OrderFeedbackSection> {
  static final _timeFormat = DateFormat('d MMM, HH:mm', 'id_ID');

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  OrderFeedback? _feedback;
  bool _loading = true;
  bool _sending = false;
  String? _validationError;
  String? _sendError;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Future<void> _loadFeedback() async {
    setState(() {
      _loading = true;
      _sendError = null;
    });

    try {
      final feedback = await widget.repository.getFeedback(widget.orderId);
      if (!mounted) return;
      setState(() {
        _feedback = feedback;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() {
        _validationError = 'Silakan tulis pesan terlebih dahulu.';
        _sendError = null;
      });
      return;
    }

    setState(() {
      _validationError = null;
      _sendError = null;
      _sending = true;
    });

    try {
      final feedback = await widget.repository.sendFeedback(
        orderId: widget.orderId,
        message: message,
      );
      if (!mounted) return;
      setState(() {
        _feedback = feedback;
        _sending = false;
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendError = 'Pesan belum berhasil dikirim. Silakan coba lagi.';
      });
    }
  }

  String _formatTime(String raw) {
    try {
      return _timeFormat.format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  Widget _buildCustomerReadReceipt(String time) {
    final receiptColor = Colors.white.withValues(alpha: 0.75);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: _poppins(
            fontSize: 10,
            color: receiptColor,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.done_all,
          size: 12,
          color: receiptColor,
        ),
      ],
    );
  }

  Widget _buildMessageBubble(OrderFeedbackMessage message) {
    final isCustomer = message.isFromCustomer;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxBubbleWidth = constraints.maxWidth * 0.78;

          return Align(
            alignment:
                isCustomer ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                right: isCustomer ? AppSpacing.s4 : 0,
                left: isCustomer ? 0 : AppSpacing.s4,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                child: Column(
                  crossAxisAlignment: isCustomer
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.senderLabel,
                      style: _poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: isCustomer
                            ? AppColors.brandBlue
                            : AppColors.brandBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isCustomer
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    message.message,
                                    style: _poppins(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildCustomerReadReceipt(
                                  _formatTime(message.createdAt),
                                ),
                              ],
                            )
                          : Text(
                              message.message,
                              style: _poppins(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                    ),
                    if (!isCustomer) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.createdAt),
                        style: _poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _feedback?.messages ?? const <OrderFeedbackMessage>[];

    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komplain / Masukan',
            style: _poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
            )
          else ...[
            if (messages.isEmpty)
              Text(
                'Ada kendala dengan pesanan ini?',
                style: _poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            if (messages.isNotEmpty) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: messages
                        .map(
                          (message) => SizedBox(
                            width: double.infinity,
                            child: _buildMessageBubble(message),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    onChanged: (_) {
                      if (_validationError != null || _sendError != null) {
                        setState(() {
                          _validationError = null;
                          _sendError = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: messages.isEmpty
                          ? 'Tulis komplain atau masukan...'
                          : 'Tulis pesan...',
                      hintStyle: _poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandBlue),
                      ),
                      errorText: _validationError,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _sending ? null : _sendMessage,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.brandBlue,
                      disabledBackgroundColor:
                          AppColors.accent.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.brandBlue,
                            ),
                          )
                        : Text(
                            'Kirim',
                            style: _poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandBlue,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (_sendError != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                _sendError!,
                style: _poppins(
                  fontSize: 12,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
