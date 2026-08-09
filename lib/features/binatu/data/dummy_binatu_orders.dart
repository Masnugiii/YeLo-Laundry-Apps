import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_order.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';

List<BinatuIroningOrder> dummyBinatuIroningOrders() {
  final now = DateTime.now();

  return [
    BinatuIroningOrder(
      id: 'binatu-001',
      orderNumber: 'YL-004291',
      customerName: 'Andi Saputra',
      service: 'Cuci Kering Setrika',
      weightKg: 4.5,
      quantityPcs: 18,
      customerNotes: 'Kemeja putih jangan pakai pewangi kuat.',
      deadline: now.add(const Duration(hours: 3)),
      ironingStatus: BinatuIroningStatus.waitingForBinatu,
      waitingStartedAt: now.subtract(const Duration(minutes: 2)),
    ),
    BinatuIroningOrder(
      id: 'binatu-002',
      orderNumber: 'YL-004290',
      customerName: 'Siti Rahayu',
      service: 'Setrika Saja',
      weightKg: 3.0,
      quantityPcs: 12,
      customerNotes: 'Lipat rapi untuk koper.',
      deadline: now.add(const Duration(hours: 2, minutes: 30)),
      ironingStatus: BinatuIroningStatus.acceptedByBinatu,
      waitingStartedAt: now.subtract(const Duration(minutes: 25)),
      assignedBinatu: 'Pak Budi',
      acceptedAt: now.subtract(const Duration(minutes: 20)),
    ),
    BinatuIroningOrder(
      id: 'binatu-003',
      orderNumber: 'YL-004289',
      customerName: 'Budi Santoso',
      service: 'Express Setrika',
      weightKg: 5.2,
      quantityPcs: 22,
      customerNotes: '-',
      deadline: now.add(const Duration(hours: 1, minutes: 45)),
      ironingStatus: BinatuIroningStatus.currentlyIroning,
      waitingStartedAt: now.subtract(const Duration(hours: 1, minutes: 10)),
      assignedBinatu: 'Pak Budi',
      acceptedAt: now.subtract(const Duration(hours: 1)),
    ),
    BinatuIroningOrder(
      id: 'binatu-004',
      orderNumber: 'YL-004288',
      customerName: 'Dewi Lestari',
      service: 'Cuci Kering Setrika',
      weightKg: 6.0,
      quantityPcs: 25,
      customerNotes: 'Pisahkan pakaian bayi.',
      deadline: now.add(const Duration(hours: 4)),
      ironingStatus: BinatuIroningStatus.finishedIroning,
      waitingStartedAt: now.subtract(const Duration(hours: 4)),
      assignedBinatu: 'Pak Budi',
      acceptedAt: now.subtract(const Duration(hours: 3)),
      finishedAt: now.subtract(const Duration(minutes: 25)),
    ),
    BinatuIroningOrder(
      id: 'binatu-005',
      orderNumber: 'YL-004287',
      customerName: 'Rina Wijaya',
      service: 'Setrika Saja',
      weightKg: 2.8,
      quantityPcs: 10,
      customerNotes: 'Antar ke meja depan.',
      deadline: now.add(const Duration(hours: 5)),
      ironingStatus: BinatuIroningStatus.readyForPickup,
      waitingStartedAt: now.subtract(const Duration(hours: 5)),
      assignedBinatu: 'Pak Budi',
      acceptedAt: now.subtract(const Duration(hours: 4)),
      finishedAt: now.subtract(const Duration(hours: 1)),
    ),
    BinatuIroningOrder(
      id: 'binatu-006',
      orderNumber: 'YL-004286',
      customerName: 'John Anderson',
      service: 'Cuci Kering Setrika',
      weightKg: 7.5,
      quantityPcs: 30,
      customerNotes: 'Semua kemeja pakai hanger.',
      deadline: now.add(const Duration(hours: 6)),
      ironingStatus: BinatuIroningStatus.waitingForBinatu,
      waitingStartedAt: now.subtract(const Duration(minutes: 4)),
    ),
    BinatuIroningOrder(
      id: 'binatu-007',
      orderNumber: 'YL-004285',
      customerName: 'Maya Putri',
      service: 'Setrika Saja',
      weightKg: 3.8,
      quantityPcs: 14,
      customerNotes: 'Prioritas sore hari.',
      deadline: now.add(const Duration(hours: 2)),
      ironingStatus: BinatuIroningStatus.waitingForOperatorAssistance,
      waitingStartedAt: now.subtract(const Duration(minutes: 8)),
      operatorAssistanceAvailableAt: now.subtract(const Duration(minutes: 3)),
    ),
  ];
}

const dummyBinatuTodaysTargetKg = 45.0;

const dummyBinatuStaffName = 'Pak Budi';

const dummyOperatorStaffName = 'Pak Budi';
