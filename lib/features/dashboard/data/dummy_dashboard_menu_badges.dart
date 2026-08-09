import 'package:yelo_laundry_erp/features/customer_service/data/dummy_whatsapp_conversations.dart';
import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';
import 'package:yelo_laundry_erp/features/notifications/data/dummy_cashier_notifications.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/data/dummy_pickup_delivery_requests.dart';
import 'package:yelo_laundry_erp/features/pickup_delivery/models/pickup_delivery_request.dart';

/// Unread Pickup & Delivery items for dashboard menu badges.
///
/// Counts new pickup/delivery requests and today's scheduled items.
int dummyPickupDeliveryUnreadCount() {
  return dummyPickupDeliveryRequests
      .where(_countsTowardPickupDeliveryBadge)
      .take(3)
      .length;
}

bool _countsTowardPickupDeliveryBadge(PickupDeliveryRequest request) {
  if (request.isToday &&
      (request.status == PickupDeliveryStatus.pickupScheduled ||
          request.status == PickupDeliveryStatus.deliveryScheduled)) {
    return true;
  }

  return request.status == PickupDeliveryStatus.pickupScheduled ||
      request.status == PickupDeliveryStatus.deliveryScheduled;
}

/// Unread Notification Center items for dashboard menu badges.
int dummyNotificationCenterUnreadCount() {
  const operationalNotifications = 2;
  final paymentNotifications =
      dummyCashierTransactionNotifications().take(5).length;

  return operationalNotifications + paymentNotifications;
}

/// Unread Customer Service conversations for dashboard menu badges.
int dummyCustomerServiceUnreadCount() {
  return dummyWhatsappConversations.where(_countsTowardCustomerServiceBadge).length;
}

bool _countsTowardCustomerServiceBadge(WhatsappConversation conversation) {
  return conversation.isUnread;
}

// Backward-compatible aliases for the Manager dashboard.
int dummyManagerPickupDeliveryUnreadCount() => dummyPickupDeliveryUnreadCount();
int dummyManagerNotificationCenterUnreadCount() =>
    dummyNotificationCenterUnreadCount();
int dummyManagerCustomerServiceUnreadCount() => dummyCustomerServiceUnreadCount();

// Operator dashboard uses the same dummy unread counters.
int dummyOperatorPickupDeliveryUnreadCount() => dummyPickupDeliveryUnreadCount();
int dummyOperatorNotificationCenterUnreadCount() =>
    dummyNotificationCenterUnreadCount();
int dummyOperatorCustomerServiceUnreadCount() => dummyCustomerServiceUnreadCount();

// Cashier dashboard uses the same dummy unread counters.
int dummyCashierPickupDeliveryUnreadCount() => dummyPickupDeliveryUnreadCount();
int dummyCashierNotificationCenterUnreadCount() =>
    dummyNotificationCenterUnreadCount();
int dummyCashierCustomerServiceUnreadCount() => dummyCustomerServiceUnreadCount();
