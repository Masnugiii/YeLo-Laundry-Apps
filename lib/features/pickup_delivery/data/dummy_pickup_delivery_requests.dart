import 'package:yelo_laundry_erp/features/pickup_delivery/models/pickup_delivery_request.dart';

final dummyPickupDeliveryRequests = <PickupDeliveryRequest>[
  PickupDeliveryRequest(
    id: 'pd-001',
    customerName: 'Andi Saputra',
    customerPhone: '+62 812 3456 7890',
    pickupTime: '09:00 WIB',
    deliveryTime: '17:00 WIB',
    address: 'Jl. Soekarno Hatta No. 12,\nProbolinggo',
    notes: 'Tolong laundry ditaruh di teras.',
    status: PickupDeliveryStatus.pickupScheduled,
    scheduledDate: DateTime(2026, 8, 7),
    mapsQuery: 'Jl. Soekarno Hatta No. 12, Probolinggo',
  ),
  PickupDeliveryRequest(
    id: 'pd-002',
    customerName: 'Siti Rahayu',
    customerPhone: '+62 813 9876 5432',
    pickupTime: '10:30 WIB',
    deliveryTime: '18:00 WIB',
    address: 'Perumahan Griya Asri Blok B7,\nPamulang, Tangerang Selatan',
    notes: 'Titip ke satpam.',
    status: PickupDeliveryStatus.pickupCompleted,
    scheduledDate: DateTime(2026, 8, 7),
    mapsQuery: 'Perumahan Griya Asri Blok B7, Pamulang',
  ),
  PickupDeliveryRequest(
    id: 'pd-003',
    customerName: 'Budi Santoso',
    customerPhone: '+62 821 1122 3344',
    pickupTime: '08:00 WIB',
    deliveryTime: '16:00 WIB',
    address: 'Jl. Sudirman No. 45,\nJakarta Selatan',
    notes: 'Hubungi sebelum datang.',
    status: PickupDeliveryStatus.deliveryScheduled,
    scheduledDate: DateTime(2026, 8, 7),
    mapsQuery: 'Jl. Sudirman No. 45, Jakarta Selatan',
  ),
  PickupDeliveryRequest(
    id: 'pd-004',
    customerName: 'Dewi Lestari',
    customerPhone: '+62 856 7788 9900',
    pickupTime: '11:00 WIB',
    deliveryTime: '19:00 WIB',
    address: 'Jl. Mawar No. 8,\nSerpong, Tangerang',
    notes: 'Jangan dibunyikan bel.',
    status: PickupDeliveryStatus.deliveryCompleted,
    scheduledDate: DateTime(2026, 8, 6),
    mapsQuery: 'Jl. Mawar No. 8, Serpong',
  ),
  PickupDeliveryRequest(
    id: 'pd-005',
    customerName: 'Rizky Pratama',
    customerPhone: '+62 877 6655 4433',
    pickupTime: '13:00 WIB',
    deliveryTime: '20:00 WIB',
    address: 'Kost Melati, BSD City,\nTangerang',
    notes: 'Parkir di area motor depan.',
    status: PickupDeliveryStatus.pickupScheduled,
    scheduledDate: DateTime(2026, 8, 8),
    mapsQuery: 'Kost Melati BSD City',
  ),
  PickupDeliveryRequest(
    id: 'pd-006',
    customerName: 'Maya Anggraini',
    customerPhone: '+62 811 2233 4455',
    pickupTime: '14:30 WIB',
    deliveryTime: '21:00 WIB',
    address: 'Apartemen Skyline Tower 12A,\nJakarta',
    notes: 'Serahkan ke unit 12A langsung.',
    status: PickupDeliveryStatus.deliveryScheduled,
    scheduledDate: DateTime(2026, 8, 8),
    mapsQuery: 'Apartemen Skyline Tower Jakarta',
  ),
];

List<PickupDeliveryRequest> filterPickupDeliveryRequests({
  required String query,
  required PickupDeliveryFilter filter,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return dummyPickupDeliveryRequests.where((request) {
    final matchesSearch = normalizedQuery.isEmpty ||
        request.customerName.toLowerCase().contains(normalizedQuery) ||
        request.customerPhone.toLowerCase().contains(normalizedQuery);

    if (!matchesSearch) {
      return false;
    }

    return switch (filter) {
      PickupDeliveryFilter.all => true,
      PickupDeliveryFilter.pickup => request.status.isPickupRelated,
      PickupDeliveryFilter.delivery => request.status.isDeliveryRelated,
      PickupDeliveryFilter.today => request.isToday,
      PickupDeliveryFilter.completed => request.status.isCompleted,
    };
  }).toList();
}
