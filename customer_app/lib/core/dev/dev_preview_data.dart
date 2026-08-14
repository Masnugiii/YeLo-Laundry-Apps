import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/network/api_response.dart';
import 'package:yelo_laundry_customer/core/session/customer_gender.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_catalog_service.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_perfume_option.dart';
import 'package:yelo_laundry_customer/features/pickup/models/customer_payment_config.dart';
import 'package:yelo_laundry_customer/features/promo/models/customer_promo.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';
import 'package:yelo_laundry_customer/features/home/data/home_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_feedback_repository.dart';
import 'package:yelo_laundry_customer/features/rewards/data/reward_repository.dart';
import 'package:yelo_laundry_customer/features/wallet/data/wallet_repository.dart';
import 'package:yelo_laundry_customer/features/claim_point/models/claim_mission.dart';

/// Dummy data for development UI preview only.
abstract final class DevPreviewData {
  static const customerId = 'dev-preview-customer';

  static const session = CustomerSession(
    id: customerId,
    fullName: 'Siti (Preview)',
    phone: '+6281234567890',
    email: null,
    gender: CustomerGender.female,
    memberSerialNumber: 'CUS-0004827',
    loyaltyPoints: 8,
    walletBalance: 150000,
    membershipLevel: MembershipLevel.gold,
  );

  static const _meta = PaginatedMeta(page: 1, limit: 20, total: 3, totalPages: 1);

  static const dashboard = DashboardData(
    greetingName: 'Ibu Siti',
    activeOrders: 2,
    readyPickup: 1,
    walletBalance: 150000,
    rewardPoints: 8,
    unreadNotifications: 2,
    latestNotifications: [
      NotificationPreview(
        id: 'dev-notif-1',
        title: 'Cucian Siap Diambil',
        message: 'Pesanan YL-2026-001 siap diambil di outlet terdekat.',
        createdAt: '2026-08-09T10:00:00Z',
        isRead: false,
      ),
      NotificationPreview(
        id: 'dev-notif-2',
        title: 'Pickup Sedang Dijemput',
        message: 'Kurir sedang menuju alamat Anda.',
        createdAt: '2026-08-09T08:30:00Z',
        isRead: true,
      ),
    ],
  );

  static final orders = [
    const OrderItem(
      id: 'dev-order-unpaid',
      orderNumber: 'YL-2026-003',
      orderStatus: 'WAITING_PAYMENT',
      paymentStatus: 'UNPAID',
      grandTotal: 85000,
      orderDate: '2026-08-09',
      pickupRequired: true,
      deliveryRequired: true,
      serviceSummary: 'Cuci Kering Setrika, Cuci Bed Cover',
    ),
    const OrderItem(
      id: 'dev-order-1',
      orderNumber: 'YL-2026-001',
      orderStatus: 'PROCESSING',
      paymentStatus: 'PAID',
      grandTotal: 85000,
      orderDate: '2026-08-09',
      pickupRequired: true,
      deliveryRequired: false,
    ),
    const OrderItem(
      id: 'dev-order-2',
      orderNumber: 'YL-2026-002',
      orderStatus: 'COMPLETED',
      paymentStatus: 'PAID',
      grandTotal: 120000,
      orderDate: '2026-08-08',
      pickupRequired: false,
      deliveryRequired: true,
      serviceSummary: 'Cuci Kering Setrika',
    ),
  ];

  static PaginatedOrders get paginatedOrders =>
      PaginatedOrders(items: orders, meta: _meta);

  static OrderDetail orderDetail(String orderId) {
    final order = orders.firstWhere(
      (item) => item.id == orderId,
      orElse: () => orders.first,
    );

    return OrderDetail(
      id: order.id,
      orderNumber: order.orderNumber,
      orderStatus: order.orderStatus,
      paymentStatus: order.paymentStatus,
      grandTotal: order.grandTotal,
      orderDate: order.orderDate,
      pickupRequired: order.pickupRequired,
      deliveryRequired: order.deliveryRequired,
      items: const [
        {
          'name': 'Cuci Kering Setrika',
          'quantity': 3,
          'unit': 'kg',
          'subtotal': 45000,
        },
        {
          'name': 'Cuci Bed Cover',
          'quantity': 1,
          'unit': 'pcs',
          'subtotal': 40000,
        },
      ],
      timeline: const [
        {'status': 'RECEIVED', 'label': 'Pesanan diterima', 'at': '2026-08-09T08:00:00Z'},
        {'status': 'PROCESSING', 'label': 'Sedang dicuci', 'at': '2026-08-09T09:30:00Z'},
      ],
      statusHistory: const [
        {'status': 'RECEIVED', 'at': '2026-08-09T08:00:00Z'},
        {'status': 'PROCESSING', 'at': '2026-08-09T09:30:00Z'},
      ],
      notes: 'Preview data — tidak tersimpan ke server.',
    );
  }

  static final laundryTracking = [
    const LaundryTrackingStep(
      key: 'received',
      label: 'Diterima',
      status: 'completed',
      completedAt: '2026-08-09T08:00:00Z',
    ),
    const LaundryTrackingStep(
      key: 'washing',
      label: 'Mencuci',
      status: 'in_progress',
    ),
    const LaundryTrackingStep(
      key: 'ready',
      label: 'Siap',
      status: 'pending',
    ),
  ];

  static Map<String, dynamic> deliveryTracking(String orderId) => {
        'status': 'ON_THE_WAY',
        'driverName': 'Pak Budi',
        'eta': '30 menit',
        'orderId': orderId,
      };

  static Map<String, dynamic> orderTimeline(String orderId) => {
        'orderId': orderId,
        'events': [
          {'label': 'Pesanan dibuat', 'at': '2026-08-09T08:00:00Z'},
          {'label': 'Sedang diproses', 'at': '2026-08-09T09:30:00Z'},
        ],
      };

  static final notifications = <AppNotification>[
    AppNotification(
      id: 'dev-notif-1',
      title: 'Order Created',
      message: 'Pesanan laundry berhasil dibuat.',
      type: 'ORDER',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      isRead: false,
      priority: 'NORMAL',
      orderNumber: 'YL-2026-003',
    ),
    AppNotification(
      id: 'dev-notif-2',
      title: 'Payment Successful',
      message: 'Pembayaran telah diterima.',
      type: 'PAYMENT',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      isRead: false,
      priority: 'NORMAL',
      orderNumber: 'YL-2026-003',
    ),
    AppNotification(
      id: 'dev-notif-3',
      title: 'Laundry Finished',
      message: 'Laundry sudah selesai.',
      type: 'LAUNDRY',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      isRead: true,
      priority: 'NORMAL',
      orderNumber: 'YL-2026-003',
    ),
    AppNotification(
      id: 'dev-notif-4',
      title: 'Delivery Started',
      message: 'Kurir sedang menuju alamat Anda.',
      type: 'DELIVERY',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
      isRead: true,
      priority: 'NORMAL',
      orderNumber: 'YL-2026-001',
    ),
    AppNotification(
      id: 'dev-notif-5',
      title: 'Promo Spesial',
      message: 'Diskon 20% untuk cuci kering.',
      type: 'PROMOTION',
      createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      isRead: true,
      priority: 'NORMAL',
    ),
  ];

  static void markAllNotificationsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
  }

  static PaginatedResponse<AppNotification> get paginatedNotifications =>
      PaginatedResponse(items: notifications, meta: _meta);

  static AppNotification notificationDetail(String id) {
    return notifications.firstWhere(
      (item) => item.id == id,
      orElse: () => notifications.first,
    );
  }

  static const wallet = WalletSummary(
    balance: 150000,
    currency: 'IDR',
    totalTopup: 300000,
    totalSpending: 150000,
  );

  static final walletTransactions = [
    const WalletTransaction(
      id: 'dev-wt-1',
      type: 'TOPUP',
      amount: 200000,
      createdAt: '2026-08-08T14:00:00Z',
      notes: 'Top up saldo',
      referenceNumber: 'TOP-001',
    ),
    const WalletTransaction(
      id: 'dev-wt-2',
      type: 'PAYMENT',
      amount: -85000,
      createdAt: '2026-08-09T08:15:00Z',
      notes: 'Pembayaran pesanan YL-2026-001',
      referenceNumber: 'PAY-001',
    ),
  ];

  static PaginatedResponse<WalletTransaction> get paginatedWalletTransactions =>
      PaginatedResponse(items: walletTransactions, meta: _meta);

  static int _previewCurrentPoints = 8;
  static final List<RewardRedemption> _previewRedemptions = [];

  /// Test-only reset for mutable preview reward state.
  static void resetRewardsPreviewForTests() {
    _previewCurrentPoints = 8;
    _previewRedemptions.clear();
  }

  static RewardSummary get rewardSummary => RewardSummary(
    currentPoints: _previewCurrentPoints,
    expiredPoints: 0,
  );

  /// Kept for MissionRepository compatibility; not shown in YeLo Rewards UI.
  static const missions = [
    ClaimMission(
      id: 'dev-mission-1',
      type: MissionType.quiz,
      title: 'Jawab Quiz Yelo',
      description: 'Selesaikan quiz singkat tentang layanan kami.',
      rewardPoints: 50,
      status: MissionStatus.available,
      ctaLabel: 'Mulai',
    ),
    ClaimMission(
      id: 'dev-mission-2',
      type: MissionType.linkAccount,
      title: 'Hubungkan Akun',
      description: 'Lengkapi profil untuk mendapatkan bonus poin.',
      rewardPoints: 100,
      status: MissionStatus.available,
      ctaLabel: 'Lengkapi',
    ),
  ];

  static const rewardCatalog = <RewardCatalogItem>[
    RewardCatalogItem(
      id: 'dev-reward-cks-5',
      code: 'CKS_5KG',
      name: 'CKS 5 KG',
      description:
          'Cuci Kering Setrika gratis maksimal 5 kg (durasi 3 hari). Kelebihan kg dibayar normal.',
      type: RewardCatalogType.laundryKg,
      costPoints: 5,
      isActive: true,
      kg: 5,
      serviceType: 'CKS',
      serviceDurationDays: 3,
      pointRewardValueIdr: 5000,
    ),
    RewardCatalogItem(
      id: 'dev-reward-bantal',
      code: 'BANTAL_PREMIUM',
      name: 'Bantal Premium',
      description: 'Tukar 5 point dengan Bantal Premium.',
      type: RewardCatalogType.physicalGoods,
      costPoints: 5,
      isActive: true,
      pointRewardValueIdr: 5000,
    ),
    RewardCatalogItem(
      id: 'dev-reward-cks-10',
      code: 'CKS_10KG',
      name: 'CKS 10 KG',
      description:
          'Cuci Kering Setrika gratis maksimal 10 kg (durasi 3 hari). Kelebihan kg dibayar normal.',
      type: RewardCatalogType.laundryKg,
      costPoints: 10,
      isActive: true,
      kg: 10,
      serviceType: 'CKS',
      serviceDurationDays: 3,
      pointRewardValueIdr: 5000,
    ),
    RewardCatalogItem(
      id: 'dev-reward-blender',
      code: 'BLENDER',
      name: 'Blender',
      description: 'Tukar 10 point dengan Blender.',
      type: RewardCatalogType.physicalGoods,
      costPoints: 10,
      isActive: true,
      pointRewardValueIdr: 5000,
    ),
    RewardCatalogItem(
      id: 'dev-reward-sprei',
      code: 'SPREI',
      name: 'Sprei',
      description: 'Tukar 10 point dengan Sprei.',
      type: RewardCatalogType.physicalGoods,
      costPoints: 10,
      isActive: true,
      pointRewardValueIdr: 5000,
    ),
    RewardCatalogItem(
      id: 'dev-reward-magic-com',
      code: 'MAGIC_COM',
      name: 'Magic Com',
      description: 'Tukar 15 point dengan Magic Com.',
      type: RewardCatalogType.physicalGoods,
      costPoints: 15,
      isActive: true,
      pointRewardValueIdr: 5000,
    ),
  ];

  static RewardCatalogItem rewardCatalogDetail(String catalogItemId) {
    return rewardCatalog.firstWhere(
      (item) => item.id == catalogItemId,
      orElse: () => rewardCatalog.first,
    );
  }

  static RedeemRewardResult redeemRewards({
    required List<RedeemRewardItemRequest> items,
    required String idempotencyKey,
  }) {
    if (items.isEmpty) {
      throw const ApiException(
        message: 'At least one reward item is required',
        type: ApiErrorType.validation,
      );
    }

    var totalCost = 0;
    final redemptionItems = <RewardRedemptionItem>[];
    for (final request in items) {
      final catalog = rewardCatalogDetail(request.catalogItemId);
      final pointsSpent = catalog.costPoints * request.quantity;
      totalCost += pointsSpent;
      redemptionItems.add(
        RewardRedemptionItem(
          id: 'dev-ri-${redemptionItems.length + 1}',
          catalogItemId: catalog.id,
          quantity: request.quantity,
          pointsSpent: pointsSpent,
          rewardName: catalog.name,
          rewardType: catalog.type,
          entitlementKg: catalog.isLaundryKg
              ? (catalog.kg ?? 0) * request.quantity
              : null,
          serviceDurationDays: catalog.serviceDurationDays,
          serviceType: catalog.serviceType,
        ),
      );
    }

    if (_previewCurrentPoints < totalCost) {
      throw const ApiException(
        message: 'Insufficient reward points for this redemption',
        type: ApiErrorType.validation,
      );
    }

    _previewCurrentPoints -= totalCost;
    final hasPhysical = redemptionItems.any(
      (item) => item.rewardType == RewardCatalogType.physicalGoods,
    );
    final redemption = RewardRedemption(
      id: 'dev-redemption-${_previewRedemptions.length + 1}',
      status: hasPhysical ? 'PENDING' : 'COMPLETED',
      totalPointsSpent: totalCost,
      createdAt: DateTime.now().toUtc().toIso8601String(),
      items: redemptionItems,
    );
    _previewRedemptions.insert(0, redemption);

    return RedeemRewardResult(
      redemption: redemption,
      availablePoints: _previewCurrentPoints,
    );
  }

  static PaginatedResponse<RewardRedemption> get paginatedRewardRedemptions =>
      PaginatedResponse(
        items: List<RewardRedemption>.unmodifiable(_previewRedemptions),
        meta: PaginatedMeta(
          page: 1,
          limit: 20,
          total: _previewRedemptions.length,
          totalPages: 1,
        ),
      );

  static final rewardHistory = [
    const RewardHistoryItem(
      id: 'dev-rh-1',
      point: 5,
      type: 'earn',
      source: 'laundry_payment',
      createdAt: '2026-08-09T08:00:00Z',
      description: 'Points from laundry payment',
      expiredAt: '2027-02-09T08:00:00Z',
    ),
    const RewardHistoryItem(
      id: 'dev-rh-2',
      point: 6,
      type: 'earn',
      source: 'deposit',
      createdAt: '2026-08-08T12:00:00Z',
      description: 'Points from wallet deposit',
      expiredAt: '2027-02-08T12:00:00Z',
    ),
    const RewardHistoryItem(
      id: 'dev-rh-3',
      point: -3,
      type: 'redeem',
      source: 'redeem',
      createdAt: '2026-08-07T10:00:00Z',
      description: 'YeLo Rewards redemption',
    ),
  ];

  static PaginatedResponse<RewardHistoryItem> get paginatedRewardHistory =>
      PaginatedResponse(items: rewardHistory, meta: _meta);

  static const catalogServices = [
    LaundryCatalogService(
      id: 'dev-service-1',
      name: 'Cuci Kering',
      unitPrice: 8000,
      unit: LaundryServiceUnit.perKg,
    ),
    LaundryCatalogService(
      id: 'dev-service-2',
      name: 'Cuci Basah',
      unitPrice: 6000,
      unit: LaundryServiceUnit.perKg,
    ),
    LaundryCatalogService(
      id: 'dev-service-3',
      name: 'Setrika',
      unitPrice: 5000,
      unit: LaundryServiceUnit.perKg,
    ),
  ];

  static const perfumeOptions = [
    LaundryPerfumeOption.none,
    LaundryPerfumeOption(id: 'dev-perfume-sakura', name: 'Sakura'),
    LaundryPerfumeOption(id: 'dev-perfume-lavender', name: 'Lavender'),
    LaundryPerfumeOption(id: 'dev-perfume-ocean', name: 'Ocean Fresh'),
    LaundryPerfumeOption(id: 'dev-perfume-downy', name: 'Downy'),
  ];

  static const paymentConfig = CustomerPaymentConfig(
    methods: [
      PaymentMethodAvailability(
        code: 'YELO_WALLET',
        name: 'Yelo Wallet',
        isActive: true,
      ),
      PaymentMethodAvailability(code: 'QRIS', name: 'QRIS', isActive: true),
      PaymentMethodAvailability(
        code: 'BANK_TRANSFER',
        name: 'Bank Transfer',
        isActive: true,
      ),
    ],
    qris: QrisPaymentConfig(
      isActive: true,
      qrPayload: '00020101021226650012ID.CO.QRIS.WWW0118936009',
      instructions: 'Scan QRIS lalu cek status pembayaran.',
    ),
    bankTransfer: BankTransferPaymentConfig(
      isActive: true,
      bankName: 'BCA',
      accountNumber: '1234567890',
      accountHolder: 'Yelo Laundry',
      instructions: 'Transfer sesuai total, lalu konfirmasi pembayaran.',
    ),
  );

  static final addresses = [
    const CustomerAddress(
      id: 'dev-address-1',
      recipientName: 'Ibu Siti',
      phone: '081234567890',
      province: 'DKI Jakarta',
      city: 'Jakarta Selatan',
      district: 'Kebayoran Baru',
      addressDetail: 'Jl. Melawai Raya No. 12',
      isDefault: true,
      postalCode: '12160',
      label: 'Rumah',
    ),
  ];

  static final promos = [
    CustomerPromo(
      id: 'dev-promo-1',
      title: 'Promo Laundry',
      description: 'Hemat untuk laundry kamu',
      discountPercent: 20,
      minTransaction: 50000,
      maxDiscount: 20000,
      expiresAt: DateTime(2026, 8, 31),
      voucherCode: 'YELO20',
      terms: 'Berlaku untuk pelanggan terdaftar. Tidak digabung dengan promo lain.',
    ),
    CustomerPromo(
      id: 'dev-promo-2',
      title: 'Promo Weekend',
      description: 'Diskon khusus akhir pekan',
      discountPercent: 15,
      minTransaction: 75000,
      expiresAt: DateTime(2026, 9, 15),
      voucherCode: 'WEEKEND15',
      terms: 'Khusus area layanan Yelo Laundry yang tercover pickup.',
    ),
  ];

  static final Map<String, List<OrderFeedbackMessage>> _orderFeedbackMessages = {
    'dev-order-2': const [
      OrderFeedbackMessage(
        id: 'dev-feedback-1',
        senderType: 'CUSTOMER',
        senderLabel: 'Anda',
        message: 'Parfum kurang terasa.',
        createdAt: '2026-08-08T14:20:00Z',
      ),
      OrderFeedbackMessage(
        id: 'dev-feedback-2',
        senderType: 'EMPLOYEE',
        senderLabel: 'Yelo',
        message: 'Terima kasih atas masukannya. Tim kami akan menindaklanjuti.',
        createdAt: '2026-08-08T15:10:00Z',
      ),
    ],
  };

  static OrderFeedback orderFeedback(String orderId) {
    final messages = List<OrderFeedbackMessage>.from(
      _orderFeedbackMessages[orderId] ?? const [],
    );

    return OrderFeedback(
      orderId: orderId,
      ticketId: messages.isEmpty ? null : 'dev-cs-ticket-1',
      status: messages.isEmpty ? null : 'OPEN',
      messages: messages,
    );
  }

  static OrderFeedback sendOrderFeedback(String orderId, String message) {
    final messages = List<OrderFeedbackMessage>.from(
      _orderFeedbackMessages[orderId] ?? const [],
    );
    messages.add(
      OrderFeedbackMessage(
        id: 'dev-feedback-${messages.length + 1}',
        senderType: 'CUSTOMER',
        senderLabel: 'Anda',
        message: message,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    _orderFeedbackMessages[orderId] = messages;

    return OrderFeedback(
      orderId: orderId,
      ticketId: 'dev-cs-ticket-1',
      status: 'OPEN',
      messages: messages,
    );
  }
}
