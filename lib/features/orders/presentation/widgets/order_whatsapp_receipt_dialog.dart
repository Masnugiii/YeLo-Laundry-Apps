import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/core/network/api_exception.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/core/utils/phone_util.dart';
import 'package:yelo_laundry_erp/features/orders/data/order_receipt_repository.dart';
import 'package:yelo_laundry_erp/features/orders/presentation/widgets/whatsapp_update_dialog.dart';

final orderReceiptRepositoryProvider = Provider<OrderReceiptRepository>((ref) {
  return OrderReceiptRepository(ref.watch(apiClientProvider));
});

class OrderWhatsappReceiptService {
  OrderWhatsappReceiptService(this._repository);

  final OrderReceiptRepository _repository;

  Future<OrderReceiptDelivery> generate(String orderId) {
    return _repository.generateReceipt(orderId);
  }

  Future<OrderReceiptDelivery> sendViaProvider({
    required String orderId,
    required String receiptId,
  }) {
    return _repository.sendReceipt(orderId: orderId, receiptId: receiptId);
  }

  Future<OrderReceiptDelivery> openManualWhatsApp({
    required String orderId,
    required String receiptId,
    required String customerPhone,
    required String messageText,
  }) async {
    final normalized = PhoneUtil.normalizeWhatsAppNumber(customerPhone);
    if (normalized == null) {
      throw const ApiException(
        message: 'Nomor WhatsApp customer belum tersedia.',
        type: ApiErrorType.validation,
      );
    }

    final uri = Uri.parse(
      'https://wa.me/$normalized?text=${Uri.encodeComponent(messageText)}',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const ApiException(
        message: 'Tidak dapat membuka WhatsApp di perangkat ini.',
        type: ApiErrorType.unknown,
      );
    }

    return _repository.recordHandoff(orderId: orderId, receiptId: receiptId);
  }
}

final orderWhatsappReceiptServiceProvider =
    Provider<OrderWhatsappReceiptService>((ref) {
  return OrderWhatsappReceiptService(ref.watch(orderReceiptRepositoryProvider));
});

Future<OrderReceiptDelivery?> showOrderWhatsappReceiptDialog(
  BuildContext context, {
  required String orderId,
  String title = 'Kirim Struk via WhatsApp',
  String? subtitle,
}) async {
  return showDialog<OrderReceiptDelivery>(
    context: context,
    builder: (context) => _OrderWhatsappReceiptDialog(
      orderId: orderId,
      title: title,
      subtitle: subtitle,
    ),
  );
}

class _OrderWhatsappReceiptDialog extends ConsumerStatefulWidget {
  const _OrderWhatsappReceiptDialog({
    required this.orderId,
    required this.title,
    this.subtitle,
  });

  final String orderId;
  final String title;
  final String? subtitle;

  @override
  ConsumerState<_OrderWhatsappReceiptDialog> createState() =>
      _OrderWhatsappReceiptDialogState();
}

class _OrderWhatsappReceiptDialogState
    extends ConsumerState<_OrderWhatsappReceiptDialog> {
  OrderReceiptDelivery? _receipt;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final receipt = await ref
          .read(orderWhatsappReceiptServiceProvider)
          .generate(widget.orderId);
      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal membuat struk.';
        _loading = false;
      });
    }
  }

  Future<void> _handleSend() async {
    final receipt = _receipt;
    if (receipt == null || _sending) return;

    if (!PhoneUtil.hasWhatsAppNumber(receipt.customerPhone)) {
      setState(() => _error = 'Nomor WhatsApp customer belum tersedia.');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final service = ref.read(orderWhatsappReceiptServiceProvider);

      if (receipt.providerAvailable) {
        final result = await service.sendViaProvider(
          orderId: widget.orderId,
          receiptId: receipt.id,
        );
        if (!mounted) return;
        if (result.isSent) {
          Navigator.of(context).pop(result);
          return;
        }
        setState(() {
          _receipt = result;
          _sending = false;
          _error = result.failureReason ??
              'Pengiriman WhatsApp belum tersedia.';
        });
        return;
      }

      final result = await service.openManualWhatsApp(
        orderId: widget.orderId,
        receiptId: receipt.id,
        customerPhone: receipt.customerPhone!,
        messageText: receipt.messageText,
      );

      if (!mounted) return;
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'Gagal mengirim struk via WhatsApp.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        widget.title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null && receipt == null
                ? Text(
                    _error!,
                    style: GoogleFonts.poppins(color: AppColors.error),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.subtitle != null) ...[
                          Text(
                            widget.subtitle!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                        ],
                        if (receipt != null) ...[
                          Text(
                            receipt.orderNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            receipt.customerName,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          WhatsappPreviewCard(message: receipt.messageText),
                          const SizedBox(height: AppSpacing.s12),
                          _StatusBanner(receipt: receipt),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.s12),
                            Text(
                              _error!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        if (receipt != null)
          FilledButton(
            onPressed: _sending ? null : _handleSend,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
            ),
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    receipt.providerAvailable
                        ? 'Kirim via WhatsApp'
                        : 'Buka WhatsApp',
                  ),
          ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.receipt});

  final OrderReceiptDelivery receipt;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (receipt.deliveryStatus) {
      'SENT' => ('WhatsApp: Terkirim', const Color(0xFF16A34A)),
      'FAILED' => ('WhatsApp: Gagal', AppColors.error),
      'NOT_CONFIGURED' => (
          'WhatsApp belum dikonfigurasi — gunakan Buka WhatsApp',
          AppColors.warning,
        ),
      _ => ('Receipt: Generated · WhatsApp: Pending', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
