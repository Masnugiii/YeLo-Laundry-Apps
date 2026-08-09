import 'package:yelo_laundry_customer/core/config/app_config.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';

class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
    required this.grandTotal,
    required this.orderDate,
    required this.pickupRequired,
    required this.deliveryRequired,
  });

  final String id;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;
  final double grandTotal;
  final String orderDate;
  final bool pickupRequired;
  final bool deliveryRequired;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      orderStatus: json['orderStatus'] as String,
      paymentStatus: json['paymentStatus'] as String,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      orderDate: json['orderDate'] as String,
      pickupRequired: json['pickupRequired'] as bool? ?? false,
      deliveryRequired: json['deliveryRequired'] as bool? ?? false,
    );
  }
}

class OrderDetail extends OrderItem {
  const OrderDetail({
    required super.id,
    required super.orderNumber,
    required super.orderStatus,
    required super.paymentStatus,
    required super.grandTotal,
    required super.orderDate,
    required super.pickupRequired,
    required super.deliveryRequired,
    required this.items,
    required this.timeline,
    required this.statusHistory,
    required this.notes,
  });

  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> timeline;
  final List<Map<String, dynamic>> statusHistory;
  final String? notes;

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      orderStatus: json['orderStatus'] as String,
      paymentStatus: json['paymentStatus'] as String,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      orderDate: json['orderDate'] as String,
      pickupRequired: json['pickupRequired'] as bool? ?? false,
      deliveryRequired: json['deliveryRequired'] as bool? ?? false,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      timeline: (json['timeline'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

class LaundryTrackingStep {
  const LaundryTrackingStep({
    required this.key,
    required this.label,
    required this.status,
    this.completedAt,
  });

  final String key;
  final String label;
  final String status;
  final String? completedAt;

  factory LaundryTrackingStep.fromJson(Map<String, dynamic> json) {
    return LaundryTrackingStep(
      key: json['key'] as String,
      label: json['label'] as String,
      status: json['status'] as String,
      completedAt: json['completedAt'] as String?,
    );
  }
}

class PaginatedOrders {
  const PaginatedOrders({required this.items, required this.meta});

  final List<OrderItem> items;
  final PaginatedMeta meta;

  factory PaginatedOrders.fromJson(Map<String, dynamic> json) {
    return PaginatedOrders(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginatedMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class OrderRepository {
  OrderRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<PaginatedOrders> getOrders({
    int page = 1,
    String? status,
    String? search,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/orders',
      queryParameters: {
        'page': page,
        'limit': AppConfig.defaultPageSize,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return PaginatedOrders.fromJson(data);
  }

  Future<OrderDetail> getOrder(String orderId) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/orders/$orderId',
      parser: (json) => json as Map<String, dynamic>,
    );
    return OrderDetail.fromJson(data);
  }

  Future<List<LaundryTrackingStep>> getLaundryTracking(String orderId) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/customer-app/orders/$orderId/laundry-tracking',
      parser: (json) => json as Map<String, dynamic>,
    );

    return (data['steps'] as List<dynamic>)
        .map((e) => LaundryTrackingStep.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>?> getDeliveryTracking(String orderId) async {
    final data = await _api.get<Map<String, dynamic>?>(
      '/customer-app/orders/$orderId/delivery-tracking',
      parser: (json) => json as Map<String, dynamic>?,
    );
    return data;
  }

  Future<Map<String, dynamic>> getTimeline(String orderId) async {
    return _api.get<Map<String, dynamic>>(
      '/customer-app/orders/$orderId/timeline',
      parser: (json) => json as Map<String, dynamic>,
    );
  }
}
