import 'package:yelo_laundry_erp/features/customer_service/models/whatsapp_conversation.dart';

const customerServiceSummary = CustomerServiceSummary(
  unreadMessages: 18,
  newComplaints: 3,
  orderQuestions: 7,
  completed: 24,
);

final List<WhatsappConversation> dummyWhatsappConversations = [
  WhatsappConversation(
    id: 'cs-001',
    customerName: 'Andi Saputra',
    whatsappNumber: '+62 812-3456-7890',
    messagePreview: 'Kak, laundry saya sudah sampai mana ya?',
    messageTime: DateTime(2026, 8, 7, 16, 42),
    aiCategory: WhatsappMessageCategory.trackingOrder,
    aiConfidence: 96,
    isUnread: true,
    relatedOrder: RelatedOrderInfo(
      queueNumber: 'A-001',
      laundryService: 'Cuci + Setrika',
      currentStatus: 'Sedang Disetrika',
      estimatedCompletion: DateTime(2026, 8, 10, 17, 0),
    ),
    aiSummary:
        'AI mendeteksi bahwa pelanggan sedang menanyakan status laundry.',
    messages: [
      WhatsappChatMessage(
        id: 'm-001',
        isFromCustomer: true,
        content: 'Halo kak, saya mau tanya status laundry saya.',
        timestamp: DateTime(2026, 8, 7, 16, 30),
      ),
      WhatsappChatMessage(
        id: 'm-002',
        isFromCustomer: true,
        content: 'Kak, laundry saya sudah sampai mana ya?',
        timestamp: DateTime(2026, 8, 7, 16, 42),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-002',
    customerName: 'Siti Rahayu',
    whatsappNumber: '+62 813-9876-5432',
    messagePreview: 'Baju putih saya ada noda setelah dicuci.',
    messageTime: DateTime(2026, 8, 7, 15, 18),
    aiCategory: WhatsappMessageCategory.komplain,
    aiConfidence: 94,
    isUnread: true,
    relatedOrder: RelatedOrderInfo(
      queueNumber: 'B-014',
      laundryService: 'Cuci Kiloan',
      currentStatus: 'Selesai',
      estimatedCompletion: DateTime(2026, 8, 7, 14, 0),
    ),
    aiSummary:
        'AI mendeteksi keluhan pelanggan terkait kualitas hasil cucian.',
    messages: [
      WhatsappChatMessage(
        id: 'm-003',
        isFromCustomer: true,
        content: 'Selamat sore kak.',
        timestamp: DateTime(2026, 8, 7, 15, 10),
      ),
      WhatsappChatMessage(
        id: 'm-004',
        isFromCustomer: true,
        content: 'Baju putih saya ada noda setelah dicuci.',
        timestamp: DateTime(2026, 8, 7, 15, 18),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-003',
    customerName: 'Budi Santoso',
    whatsappNumber: '+62 821-1122-3344',
    messagePreview: 'Mau order cuci express 5 kg, bisa pickup hari ini?',
    messageTime: DateTime(2026, 8, 7, 14, 55),
    aiCategory: WhatsappMessageCategory.orderBaru,
    aiConfidence: 92,
    isUnread: true,
    aiSummary:
        'AI mendeteksi pelanggan ingin membuat order laundry baru dengan layanan express.',
    messages: [
      WhatsappChatMessage(
        id: 'm-005',
        isFromCustomer: true,
        content: 'Halo, mau order cuci express 5 kg.',
        timestamp: DateTime(2026, 8, 7, 14, 50),
      ),
      WhatsappChatMessage(
        id: 'm-006',
        isFromCustomer: true,
        content: 'Mau order cuci express 5 kg, bisa pickup hari ini?',
        timestamp: DateTime(2026, 8, 7, 14, 55),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-004',
    customerName: 'Dewi Lestari',
    whatsappNumber: '+62 856-7788-9900',
    messagePreview: 'Berapa biaya cuci bed cover ukuran king?',
    messageTime: DateTime(2026, 8, 7, 13, 20),
    aiCategory: WhatsappMessageCategory.pertanyaan,
    aiConfidence: 89,
    isUnread: false,
    aiSummary:
        'AI mendeteksi pelanggan menanyakan informasi harga layanan laundry.',
    messages: [
      WhatsappChatMessage(
        id: 'm-007',
        isFromCustomer: true,
        content: 'Berapa biaya cuci bed cover ukuran king?',
        timestamp: DateTime(2026, 8, 7, 13, 20),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-005',
    customerName: 'Rizky Pratama',
    whatsappNumber: '+62 877-5544-3322',
    messagePreview: 'Ada promo member baru bulan ini?',
    messageTime: DateTime(2026, 8, 7, 11, 05),
    aiCategory: WhatsappMessageCategory.promo,
    aiConfidence: 91,
    isUnread: false,
    aiSummary:
        'AI mendeteksi pelanggan menanyakan informasi promo atau diskon.',
    messages: [
      WhatsappChatMessage(
        id: 'm-008',
        isFromCustomer: true,
        content: 'Ada promo member baru bulan ini?',
        timestamp: DateTime(2026, 8, 7, 11, 05),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-006',
    customerName: 'Maya Anggraini',
    whatsappNumber: '+62 812-6677-8899',
    messagePreview: 'Terima kasih, sudah diambil ya kak.',
    messageTime: DateTime(2026, 8, 7, 10, 30),
    aiCategory: WhatsappMessageCategory.lainnya,
    aiConfidence: 78,
    isUnread: false,
    relatedOrder: RelatedOrderInfo(
      queueNumber: 'C-022',
      laundryService: 'Setrika Saja',
      currentStatus: 'Selesai',
      estimatedCompletion: DateTime(2026, 8, 7, 10, 0),
    ),
    aiSummary:
        'AI mendeteksi pesan umum dari pelanggan tanpa permintaan spesifik.',
    messages: [
      WhatsappChatMessage(
        id: 'm-009',
        isFromCustomer: true,
        content: 'Terima kasih, sudah diambil ya kak.',
        timestamp: DateTime(2026, 8, 7, 10, 30),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-007',
    customerName: 'John Anderson',
    whatsappNumber: '+62 811-2233-4455',
    messagePreview: 'Kapan estimasi selesai order A-008?',
    messageTime: DateTime(2026, 8, 7, 9, 15),
    aiCategory: WhatsappMessageCategory.trackingOrder,
    aiConfidence: 95,
    isUnread: true,
    relatedOrder: RelatedOrderInfo(
      queueNumber: 'A-008',
      laundryService: 'Express',
      currentStatus: 'Sedang Dicuci',
      estimatedCompletion: DateTime(2026, 8, 8, 12, 0),
    ),
    aiSummary:
        'AI mendeteksi bahwa pelanggan sedang menanyakan estimasi penyelesaian order.',
    messages: [
      WhatsappChatMessage(
        id: 'm-010',
        isFromCustomer: true,
        content: 'Kapan estimasi selesai order A-008?',
        timestamp: DateTime(2026, 8, 7, 9, 15),
      ),
    ],
  ),
  WhatsappConversation(
    id: 'cs-008',
    customerName: 'Fitri Handayani',
    whatsappNumber: '+62 858-9900-1122',
    messagePreview: 'Selimut saya belum kering sempurna.',
    messageTime: DateTime(2026, 8, 6, 18, 40),
    aiCategory: WhatsappMessageCategory.komplain,
    aiConfidence: 93,
    isUnread: true,
    relatedOrder: RelatedOrderInfo(
      queueNumber: 'D-005',
      laundryService: 'Cuci Kiloan',
      currentStatus: 'Sedang Dikeringkan',
      estimatedCompletion: DateTime(2026, 8, 7, 16, 0),
    ),
    aiSummary:
        'AI mendeteksi keluhan pelanggan terkait proses pengeringan laundry.',
    messages: [
      WhatsappChatMessage(
        id: 'm-011',
        isFromCustomer: true,
        content: 'Selimut saya belum kering sempurna.',
        timestamp: DateTime(2026, 8, 6, 18, 40),
      ),
    ],
  ),
];

WhatsappConversation? findWhatsappConversationById(String id) {
  for (final conversation in dummyWhatsappConversations) {
    if (conversation.id == id) return conversation;
  }
  return null;
}

List<WhatsappConversation> filterWhatsappConversations({
  required List<WhatsappConversation> conversations,
  required String query,
  required WhatsappConversationFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return conversations.where((conversation) {
    final matchesFilter = switch (filter) {
      WhatsappConversationFilter.semua => true,
      WhatsappConversationFilter.orderBaru =>
        conversation.aiCategory == WhatsappMessageCategory.orderBaru,
      WhatsappConversationFilter.komplain =>
        conversation.aiCategory == WhatsappMessageCategory.komplain,
      WhatsappConversationFilter.pertanyaan =>
        conversation.aiCategory == WhatsappMessageCategory.pertanyaan ||
            conversation.aiCategory == WhatsappMessageCategory.trackingOrder,
      WhatsappConversationFilter.promo =>
        conversation.aiCategory == WhatsappMessageCategory.promo,
      WhatsappConversationFilter.lainnya =>
        conversation.aiCategory == WhatsappMessageCategory.lainnya,
    };

    if (!matchesFilter) return false;

    if (normalizedQuery.isEmpty) return true;

    return conversation.customerName.toLowerCase().contains(normalizedQuery) ||
        conversation.whatsappNumber.toLowerCase().contains(normalizedQuery);
  }).toList();
}
