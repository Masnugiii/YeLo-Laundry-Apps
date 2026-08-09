import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/binatu/data/dummy_binatu_dashboard_badges.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_ironing_status.dart';

class BinatuDashboardBadgeState {
  const BinatuDashboardBadgeState({
    required this.ironingQueueUnreadCount,
    required this.currentlyIroningUnreadCount,
    required this.finishedIroningUnreadCount,
    required this.readyForPickupUnreadCount,
  });

  final int ironingQueueUnreadCount;
  final int currentlyIroningUnreadCount;
  final int finishedIroningUnreadCount;
  final int readyForPickupUnreadCount;

  BinatuDashboardBadgeState copyWith({
    int? ironingQueueUnreadCount,
    int? currentlyIroningUnreadCount,
    int? finishedIroningUnreadCount,
    int? readyForPickupUnreadCount,
  }) {
    return BinatuDashboardBadgeState(
      ironingQueueUnreadCount:
          ironingQueueUnreadCount ?? this.ironingQueueUnreadCount,
      currentlyIroningUnreadCount:
          currentlyIroningUnreadCount ?? this.currentlyIroningUnreadCount,
      finishedIroningUnreadCount:
          finishedIroningUnreadCount ?? this.finishedIroningUnreadCount,
      readyForPickupUnreadCount:
          readyForPickupUnreadCount ?? this.readyForPickupUnreadCount,
    );
  }
}

class BinatuDashboardBadgeNotifier extends Notifier<BinatuDashboardBadgeState> {
  @override
  BinatuDashboardBadgeState build() {
    return BinatuDashboardBadgeState(
      ironingQueueUnreadCount: dummyBinatuIroningQueueUnreadCount(),
      currentlyIroningUnreadCount: dummyBinatuCurrentlyIroningUnreadCount(),
      finishedIroningUnreadCount: dummyBinatuFinishedIroningUnreadCount(),
      readyForPickupUnreadCount: dummyBinatuReadyForPickupUnreadCount(),
    );
  }

  void markIroningQueueRead() {
    if (state.ironingQueueUnreadCount == 0) return;
    state = state.copyWith(ironingQueueUnreadCount: 0);
  }

  void markCurrentlyIroningRead() {
    if (state.currentlyIroningUnreadCount == 0) return;
    state = state.copyWith(currentlyIroningUnreadCount: 0);
  }

  void markFinishedIroningRead() {
    if (state.finishedIroningUnreadCount == 0) return;
    state = state.copyWith(finishedIroningUnreadCount: 0);
  }

  void markReadyForPickupRead() {
    if (state.readyForPickupUnreadCount == 0) return;
    state = state.copyWith(readyForPickupUnreadCount: 0);
  }
}

final binatuDashboardBadgeProvider =
    NotifierProvider<BinatuDashboardBadgeNotifier, BinatuDashboardBadgeState>(
  BinatuDashboardBadgeNotifier.new,
);

void markBinatuQueueBadgeRead(WidgetRef ref, BinatuQueueFilter filter) {
  final notifier = ref.read(binatuDashboardBadgeProvider.notifier);

  switch (filter) {
    case BinatuQueueFilter.ironingQueue:
      notifier.markIroningQueueRead();
    case BinatuQueueFilter.currentlyIroning:
      notifier.markCurrentlyIroningRead();
    case BinatuQueueFilter.finishedIroning:
      notifier.markFinishedIroningRead();
    case BinatuQueueFilter.readyForPickup:
      notifier.markReadyForPickupRead();
  }
}
