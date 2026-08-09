import 'package:flutter/material.dart';

enum WhatsappMessageCategory {
  orderBaru,
  komplain,
  pertanyaan,
  promo,
  trackingOrder,
  lainnya,
}

extension WhatsappMessageCategoryX on WhatsappMessageCategory {
  String get label => switch (this) {
        WhatsappMessageCategory.orderBaru => 'Order Baru',
        WhatsappMessageCategory.komplain => 'Komplain',
        WhatsappMessageCategory.pertanyaan => 'Pertanyaan',
        WhatsappMessageCategory.promo => 'Promo',
        WhatsappMessageCategory.trackingOrder => 'Tracking Order',
        WhatsappMessageCategory.lainnya => 'Lainnya',
      };

  Color get backgroundColor => switch (this) {
        WhatsappMessageCategory.orderBaru => const Color(0xFFE3F2FD),
        WhatsappMessageCategory.komplain => const Color(0xFFFFEBEE),
        WhatsappMessageCategory.pertanyaan => const Color(0xFFFFF8E1),
        WhatsappMessageCategory.promo => const Color(0xFFF3E5F5),
        WhatsappMessageCategory.trackingOrder => const Color(0xFFE8F5E9),
        WhatsappMessageCategory.lainnya => const Color(0xFFECEFF1),
      };

  Color get textColor => switch (this) {
        WhatsappMessageCategory.orderBaru => const Color(0xFF033B8E),
        WhatsappMessageCategory.komplain => const Color(0xFFC62828),
        WhatsappMessageCategory.pertanyaan => const Color(0xFFF57F17),
        WhatsappMessageCategory.promo => const Color(0xFF6A1B9A),
        WhatsappMessageCategory.trackingOrder => const Color(0xFF2E7D32),
        WhatsappMessageCategory.lainnya => const Color(0xFF546E7A),
      };

  static const manualCategories = [
    WhatsappMessageCategory.orderBaru,
    WhatsappMessageCategory.komplain,
    WhatsappMessageCategory.trackingOrder,
    WhatsappMessageCategory.pertanyaan,
    WhatsappMessageCategory.promo,
    WhatsappMessageCategory.lainnya,
  ];
}

enum WhatsappConversationFilter {
  semua,
  orderBaru,
  komplain,
  pertanyaan,
  promo,
  lainnya,
}

extension WhatsappConversationFilterX on WhatsappConversationFilter {
  String get label => switch (this) {
        WhatsappConversationFilter.semua => 'Semua',
        WhatsappConversationFilter.orderBaru => 'Order Baru',
        WhatsappConversationFilter.komplain => 'Komplain',
        WhatsappConversationFilter.pertanyaan => 'Pertanyaan',
        WhatsappConversationFilter.promo => 'Promo',
        WhatsappConversationFilter.lainnya => 'Lainnya',
      };

  static const values = WhatsappConversationFilter.values;
}

class CustomerServiceSummary {
  const CustomerServiceSummary({
    required this.unreadMessages,
    required this.newComplaints,
    required this.orderQuestions,
    required this.completed,
  });

  final int unreadMessages;
  final int newComplaints;
  final int orderQuestions;
  final int completed;
}

class RelatedOrderInfo {
  const RelatedOrderInfo({
    required this.queueNumber,
    required this.laundryService,
    required this.currentStatus,
    required this.estimatedCompletion,
  });

  final String queueNumber;
  final String laundryService;
  final String currentStatus;
  final DateTime estimatedCompletion;
}

class WhatsappChatMessage {
  const WhatsappChatMessage({
    required this.id,
    required this.isFromCustomer,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final bool isFromCustomer;
  final String content;
  final DateTime timestamp;
}

class WhatsappConversation {
  const WhatsappConversation({
    required this.id,
    required this.customerName,
    required this.whatsappNumber,
    required this.messagePreview,
    required this.messageTime,
    required this.aiCategory,
    required this.aiConfidence,
    required this.isUnread,
    required this.messages,
    required this.aiSummary,
    this.relatedOrder,
  });

  final String id;
  final String customerName;
  final String whatsappNumber;
  final String messagePreview;
  final DateTime messageTime;
  final WhatsappMessageCategory aiCategory;
  final int aiConfidence;
  final bool isUnread;
  final RelatedOrderInfo? relatedOrder;
  final List<WhatsappChatMessage> messages;
  final String aiSummary;

  WhatsappConversation copyWith({
    WhatsappMessageCategory? aiCategory,
    int? aiConfidence,
    bool? isUnread,
  }) {
    return WhatsappConversation(
      id: id,
      customerName: customerName,
      whatsappNumber: whatsappNumber,
      messagePreview: messagePreview,
      messageTime: messageTime,
      aiCategory: aiCategory ?? this.aiCategory,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      isUnread: isUnread ?? this.isUnread,
      relatedOrder: relatedOrder,
      messages: messages,
      aiSummary: aiSummary,
    );
  }
}

String formatWhatsappMessageTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final time = '$hour.$minute';

  if (messageDate == today) {
    return time;
  }

  if (messageDate == today.subtract(const Duration(days: 1))) {
    return 'Kemarin, $time';
  }

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${dateTime.day} ${months[dateTime.month - 1]}, $time';
}

String formatEstimatedCompletion(DateTime dateTime) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}\n$hour.$minute WIB';
}
