import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/binatu/models/ironing_queue_priority_settings.dart';

class IroningQueuePriorityNotifier
    extends Notifier<IroningQueuePrioritySettings> {
  @override
  IroningQueuePrioritySettings build() =>
      defaultIroningQueuePrioritySettings;

  void updateSettings(IroningQueuePrioritySettings settings) {
    state = settings;
  }

  void setBinatuFirst(bool value) {
    state = state.copyWith(binatuFirst: value);
  }

  void setWaitingTimeMinutes(int minutes) {
    state = state.copyWith(waitingTimeMinutes: minutes);
  }

  void setAllowOperatorAssistance(bool value) {
    state = state.copyWith(allowOperatorAssistance: value);
  }
}

final ironingQueuePriorityProvider = NotifierProvider<
    IroningQueuePriorityNotifier, IroningQueuePrioritySettings>(
  IroningQueuePriorityNotifier.new,
);
