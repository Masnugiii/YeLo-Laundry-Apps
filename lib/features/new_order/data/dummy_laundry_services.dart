import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';

const dummyLaundryServices = <LaundryService>[
  LaundryService(
    id: 'svc-001',
    name: 'Cuci Kering Lipat',
    unitPrice: 7000,
    unit: ServiceUnit.perKg,
    description: 'Cuci, kering, dan dilipat rapi.',
  ),
  LaundryService(
    id: 'svc-002',
    name: 'Cuci Kering Setrika',
    unitPrice: 8000,
    unit: ServiceUnit.perKg,
    description: 'Cuci, kering, dan disetrika.',
  ),
  LaundryService(
    id: 'svc-003',
    name: 'Express',
    unitPrice: 12000,
    unit: ServiceUnit.perKg,
    description: 'Selesai dalam 24 jam.',
  ),
  LaundryService(
    id: 'svc-004',
    name: 'Bed Cover',
    unitPrice: 35000,
    unit: ServiceUnit.perItem,
    description: 'Per item bed cover.',
  ),
  LaundryService(
    id: 'svc-005',
    name: 'Sepatu',
    unitPrice: 45000,
    unit: ServiceUnit.perItem,
    description: 'Cuci sepatu per pasang.',
  ),
];
