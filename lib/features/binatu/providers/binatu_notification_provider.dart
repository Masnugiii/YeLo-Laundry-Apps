import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yelo_laundry_erp/features/binatu/data/dummy_binatu_notifications.dart';
import 'package:yelo_laundry_erp/features/binatu/models/binatu_notification.dart';

class BinatuNotificationNotifier extends Notifier<List<BinatuNotification>> {
  @override
  List<BinatuNotification> build() => List.of(dummyBinatuNotifications());

  void prepend(BinatuNotification notification) {
    state = [notification, ...state];
  }
}

final binatuNotificationProvider =
    NotifierProvider<BinatuNotificationNotifier, List<BinatuNotification>>(
  BinatuNotificationNotifier.new,
);
