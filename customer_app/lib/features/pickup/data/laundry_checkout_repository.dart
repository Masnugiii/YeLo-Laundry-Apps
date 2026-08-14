import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_data.dart';
import 'package:yelo_laundry_customer/core/dev/dev_preview_gate.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_method.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_payment_status.dart';
import 'package:yelo_laundry_customer/features/pickup/models/laundry_checkout_draft.dart';

class LaundryCheckoutRepository {
  LaundryCheckoutRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  static const _missingOrderPaymentMessage =
      'Pembuatan pesanan belum dapat diproses. Periksa koneksi atau coba lagi.';

  Future<LaundryCheckoutResult> submit(LaundryCheckoutDraft draft) async {
    if (DevPreviewGate.isActive) {
      return _submitDevPreview(draft);
    }

    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/customer-app/orders',
        data: _buildOrderPayload(draft),
        parser: (json) => json as Map<String, dynamic>,
      );

      return _mapSubmitResponse(response, draft);
    } on ApiException catch (error) {
      throw CheckoutApiException(error.message);
    } catch (_) {
      throw CheckoutApiException(_missingOrderPaymentMessage);
    }
  }

  Future<CheckoutPaymentStatus> refreshPaymentStatus(String orderId) async {
    if (DevPreviewGate.isActive) {
      final detail = DevPreviewData.orderDetail(orderId);
      return CheckoutPaymentStatus.fromRaw(detail.paymentStatus);
    }

    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/orders/$orderId',
      parser: (json) => json as Map<String, dynamic>,
    );

    final order = _unwrapOrder(data);
    return CheckoutPaymentStatus.fromRaw(order['paymentStatus'] as String?);
  }

  Future<CheckoutPaymentStatus> requestOrderPayment({
    required String orderId,
    required String paymentMethodCode,
  }) async {
    if (DevPreviewGate.isActive) {
      return const CheckoutPaymentStatus('UNPAID');
    }

    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/customer-app/orders/$orderId/pay',
        data: {'paymentMethod': paymentMethodCode},
        parser: (json) => json as Map<String, dynamic>,
      );

      final order = _unwrapOrder(response);
      return CheckoutPaymentStatus.fromRaw(order['paymentStatus'] as String?);
    } on ApiException catch (error) {
      throw CheckoutApiException(error.message);
    } catch (_) {
      throw CheckoutApiException(
        'Pembayaran order belum dapat diproses. Periksa koneksi atau coba lagi.',
      );
    }
  }

  LaundryCheckoutResult _mapSubmitResponse(
    Map<String, dynamic> response,
    LaundryCheckoutDraft draft,
  ) {
    final order = _unwrapOrder(response);
    final paymentStatus =
        CheckoutPaymentStatus.fromRaw(order['paymentStatus'] as String?);

    return LaundryCheckoutResult(
      orderId: order['id'] as String,
      orderNumber: order['orderNumber'] as String? ?? '-',
      paymentStatus: paymentStatus,
      grandTotal: draft.grandTotal,
      pickup: draft.pickup,
      delivery: draft.delivery,
      selectedPerfume: draft.selectedPerfume,
      lines: draft.lines,
      paymentMethodLabel: _paymentLabel(draft.paymentMethodCode),
      usePickupDelivery: true,
    );
  }

  Map<String, dynamic> _unwrapOrder(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    return response;
  }

  Map<String, dynamic> _buildOrderPayload(LaundryCheckoutDraft draft) {
    return {
      'items': [
        for (final line in draft.lines)
          {
            'serviceId': line.service.id,
            'quantity': line.quantity,
          },
      ],
      'pickupRequired': true,
      'deliveryRequired': true,
      'notes': _composeNotes(draft),
      'paymentMethod': draft.paymentMethodCode,
    };
  }

  String _composeNotes(LaundryCheckoutDraft draft) {
    final buffer = StringBuffer();
    if (draft.notes.isNotEmpty) {
      buffer.writeln(draft.notes);
    }
    buffer.writeln('Parfum: ${draft.perfumeLabel}');
    buffer.writeln('Pickup: ${draft.pickup.displayLabel}');
    if (draft.pickup.hasCoordinates) {
      buffer.writeln(
        'Pickup koordinat: ${draft.pickup.latitude}, ${draft.pickup.longitude}',
      );
    }
    buffer.writeln('Delivery: ${draft.delivery.displayLabel}');
    if (draft.delivery.hasCoordinates) {
      buffer.writeln(
        'Delivery koordinat: ${draft.delivery.latitude}, ${draft.delivery.longitude}',
      );
    }
    return buffer.toString().trim();
  }

  Future<LaundryCheckoutResult> _submitDevPreview(
    LaundryCheckoutDraft draft,
  ) async {
    final order = DevPreviewData.orders.first;

    return LaundryCheckoutResult(
      orderId: order.id,
      orderNumber: order.orderNumber,
      paymentStatus: const CheckoutPaymentStatus('UNPAID'),
      grandTotal: draft.grandTotal,
      pickup: draft.pickup,
      delivery: draft.delivery,
      selectedPerfume: draft.selectedPerfume,
      lines: draft.lines,
      paymentMethodLabel: _paymentLabel(draft.paymentMethodCode),
      usePickupDelivery: true,
    );
  }

  String _paymentLabel(String code) => CheckoutPaymentMethods.label(code);
}
