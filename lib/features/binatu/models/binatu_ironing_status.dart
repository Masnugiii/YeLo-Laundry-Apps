import 'package:flutter/material.dart';

enum BinatuIroningStatus {
  waitingForBinatu,
  waitingForOperatorAssistance,
  acceptedByBinatu,
  currentlyIroning,
  finishedIroning,
  readyForPickup,
}

extension BinatuIroningStatusX on BinatuIroningStatus {
  String get label => switch (this) {
        BinatuIroningStatus.waitingForBinatu => 'Waiting for Binatu',
        BinatuIroningStatus.waitingForOperatorAssistance =>
          'Waiting for Operator Assistance',
        BinatuIroningStatus.acceptedByBinatu => 'Accepted by Binatu',
        BinatuIroningStatus.currentlyIroning => 'Currently Ironing',
        BinatuIroningStatus.finishedIroning => 'Finished Ironing',
        BinatuIroningStatus.readyForPickup => 'Ready for Pickup',
      };

  Color get backgroundColor => switch (this) {
        BinatuIroningStatus.waitingForBinatu => const Color(0xFFF59E0B),
        BinatuIroningStatus.waitingForOperatorAssistance =>
          const Color(0xFFEA580C),
        BinatuIroningStatus.acceptedByBinatu => const Color(0xFF2563EB),
        BinatuIroningStatus.currentlyIroning => const Color(0xFF033B8E),
        BinatuIroningStatus.finishedIroning => const Color(0xFF16A34A),
        BinatuIroningStatus.readyForPickup => const Color(0xFF7C3AED),
      };

  Color get textColor => switch (this) {
        BinatuIroningStatus.waitingForBinatu => const Color(0xFF1F2937),
        BinatuIroningStatus.waitingForOperatorAssistance =>
          const Color(0xFF1F2937),
        _ => Colors.white,
      };
}

enum BinatuQueueFilter {
  ironingQueue,
  currentlyIroning,
  finishedIroning,
  readyForPickup,
}

extension BinatuQueueFilterX on BinatuQueueFilter {
  String get label => switch (this) {
        BinatuQueueFilter.ironingQueue => 'Ironing Queue',
        BinatuQueueFilter.currentlyIroning => 'Currently Ironing',
        BinatuQueueFilter.finishedIroning => 'Finished Ironing',
        BinatuQueueFilter.readyForPickup => 'Ready for Pickup',
      };

  bool matches(BinatuIroningStatus status) => switch (this) {
        BinatuQueueFilter.ironingQueue =>
          status == BinatuIroningStatus.waitingForBinatu ||
              status == BinatuIroningStatus.waitingForOperatorAssistance ||
              status == BinatuIroningStatus.acceptedByBinatu,
        BinatuQueueFilter.currentlyIroning =>
          status == BinatuIroningStatus.currentlyIroning,
        BinatuQueueFilter.finishedIroning =>
          status == BinatuIroningStatus.finishedIroning,
        BinatuQueueFilter.readyForPickup =>
          status == BinatuIroningStatus.readyForPickup,
      };
}
