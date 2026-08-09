import 'package:yelo_laundry_erp/core/network/api_client.dart';
import 'package:yelo_laundry_erp/core/network/api_response.dart';
import 'package:yelo_laundry_erp/features/orders/models/incoming_order.dart';
import 'package:yelo_laundry_erp/features/orders/models/order_timeline_entry.dart';

class OrderRepository {
  OrderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<PaginatedResponse<IncomingOrder>> fetchOrders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? paymentStatus,
    String? dateFrom,
    String? dateTo,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/orders',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((item) => _mapOrder(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      meta: PaginatedMeta.fromJson(data['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Future<IncomingOrder> fetchOrder(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/orders/$id',
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapOrder(data, includeTimeline: true);
  }

  Future<Map<String, dynamic>> fetchStatistics() async {
    return _apiClient.get<Map<String, dynamic>>(
      '/orders/statistics',
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  Future<IncomingOrder> createOrder(Map<String, dynamic> payload) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/orders',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapOrder(data, includeTimeline: true);
  }

  Future<IncomingOrder> updateOrder(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/orders/$id',
      data: payload,
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapOrder(data, includeTimeline: true);
  }

  Future<IncomingOrder> cancelOrder(String id, String reason) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/orders/$id/cancel',
      data: {'reason': reason},
      parser: (json) => json as Map<String, dynamic>,
    );
    return _mapOrder(data, includeTimeline: true);
  }

  IncomingOrder _mapOrder(
    Map<String, dynamic> json, {
    bool includeTimeline = false,
  }) {
    final timeline = includeTimeline
        ? (json['timeline'] as List<dynamic>? ?? const [])
            .map(
              (entry) => OrderTimelineEntry(
                id: entry['id'] as String? ?? '',
                time: DateTime.tryParse(entry['createdAt'] as String? ?? '') ??
                    DateTime.now(),
                title: entry['title'] as String? ?? '',
                actorName: entry['actorName'] as String? ?? 'System',
              ),
            )
            .toList()
        : const <OrderTimelineEntry>[];

    return IncomingOrder(
      id: json['id'] as String,
      queueNumber: json['queueNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      service: LaundryServiceType.regular,
      serviceDisplayName: json['primaryServiceName'] as String?,
      orderValue: (json['grandTotal'] as num?)?.toInt() ?? 0,
      fulfillmentType: json['deliveryRequired'] == true
          ? FulfillmentType.delivery
          : json['pickupRequired'] == true
              ? FulfillmentType.pickup
              : FulfillmentType.selfPickup,
      receivedAt: DateTime.tryParse(json['orderDate'] as String? ?? '') ??
          DateTime.now(),
      estimatedCompletion:
          DateTime.tryParse(json['estimatedFinishDate'] as String? ?? '') ??
              DateTime.now().add(const Duration(days: 2)),
      currentStep: OrderWorkflowStep.orderReceived,
      status: _mapStatus(json['orderStatus'] as String?),
      picAssignment: const PicAssignment(
        pickup: '-',
        washing: '-',
        ironing: '-',
        qualityCheck: '-',
        delivery: '-',
      ),
      weightKg: (json['totalWeightKg'] as num?)?.toDouble() ?? 0,
      paymentStatus: (json['paymentStatus'] as String?) == 'PAID'
          ? OrderPaymentStatus.lunas
          : OrderPaymentStatus.belumLunas,
      timelineEntries: timeline,
    );
  }

  IncomingOrderStatus _mapStatus(String? status) {
    switch (status) {
      case 'CANCELLED':
        return IncomingOrderStatus.selesai;
      case 'COMPLETED':
      case 'DELIVERED':
        return IncomingOrderStatus.selesai;
      case 'CURRENTLY_IRONING':
      case 'FINISHED_IRONING':
        return IncomingOrderStatus.sedangDisetrika;
      case 'WAITING_BINATU':
      case 'IRONING_ACCEPTED':
        return IncomingOrderStatus.orderBaru;
      case 'OUT_FOR_DELIVERY':
        return IncomingOrderStatus.sedangDelivery;
      case 'READY_FOR_PICKUP':
        return IncomingOrderStatus.siapDiambil;
      default:
        return IncomingOrderStatus.orderBaru;
    }
  }
}
