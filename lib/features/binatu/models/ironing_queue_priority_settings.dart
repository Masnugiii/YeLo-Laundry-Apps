/// Configurable ironing queue priority for Binatu vs Operator roles.
class IroningQueuePrioritySettings {
  const IroningQueuePrioritySettings({
    this.binatuFirst = true,
    this.waitingTimeMinutes = 5,
    this.allowOperatorAssistance = true,
  });

  final bool binatuFirst;
  final int waitingTimeMinutes;
  final bool allowOperatorAssistance;

  Duration get waitingDuration => Duration(minutes: waitingTimeMinutes);

  IroningQueuePrioritySettings copyWith({
    bool? binatuFirst,
    int? waitingTimeMinutes,
    bool? allowOperatorAssistance,
  }) {
    return IroningQueuePrioritySettings(
      binatuFirst: binatuFirst ?? this.binatuFirst,
      waitingTimeMinutes: waitingTimeMinutes ?? this.waitingTimeMinutes,
      allowOperatorAssistance:
          allowOperatorAssistance ?? this.allowOperatorAssistance,
    );
  }
}

const defaultIroningQueuePrioritySettings = IroningQueuePrioritySettings();

const ironingQueueWaitingTimeOptions = [3, 5, 10, 15];
