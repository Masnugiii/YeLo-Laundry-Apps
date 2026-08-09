import 'package:yelo_laundry_erp/features/settings/models/reminder_recipient_employee.dart';

/// UI-only settings state prepared for future backend integration.
enum CleaningFrequency {
  daily,
  every3Days,
  weekly,
  every2Weeks,
  monthly,
}

extension CleaningFrequencyX on CleaningFrequency {
  String get label => switch (this) {
        CleaningFrequency.daily => 'Daily',
        CleaningFrequency.every3Days => 'Every 3 Days',
        CleaningFrequency.weekly => 'Weekly',
        CleaningFrequency.every2Weeks => 'Every 2 Weeks',
        CleaningFrequency.monthly => 'Monthly',
      };
}

const cleaningFrequencyOptions = CleaningFrequency.values;

const cleaningReminderTimes = ['08:00', '12:00', '17:00', '20:00'];

const defaultCleaningChecklistItems = <String>[
  'Clean Washing Machine',
  'Clean Dryer',
  'Clean Ironing Area',
  'Clean Folding Table',
  'Clean Customer Waiting Area',
  'Clean Cashier Counter',
  'Clean Laundry Shelves',
  'Mop the Floor',
  'Clean Bathroom',
  'Clean Machine Filters',
  'Clean Water Drain',
];

Map<String, bool> defaultCleaningChecklist() => {
      for (final item in defaultCleaningChecklistItems) item: true,
    };

class WhatsappRecipientInfo {
  const WhatsappRecipientInfo({
    required this.role,
    required this.phone,
  });

  final String role;
  final String phone;
}

const reminderRecipientContacts = [
  WhatsappRecipientInfo(role: 'Owner', phone: '0812-3456-7890'),
  WhatsappRecipientInfo(role: 'Manager', phone: '0813-5678-1234'),
];

const routineCleaningWhatsappRecipients = reminderRecipientContacts;

const maintenanceReminderIntervalLabel = 'Setiap 2 Bulan';

class UpcomingMaintenanceSchedule {
  const UpcomingMaintenanceSchedule({
    required this.machineServiceDate,
    required this.routineCleaningDate,
  });

  final String machineServiceDate;
  final String routineCleaningDate;
}

const upcomingMaintenanceSchedule = UpcomingMaintenanceSchedule(
  machineServiceDate: '08 Oktober 2026',
  routineCleaningDate: '08 Oktober 2026',
);

class AppSettingsState {
  const AppSettingsState({
    // Notification
    this.soundOnNewOrder = true,
    this.vibrateOnNewOrder = true,
    this.showNewOrderPopup = true,
    // Maintenance — machine service
    this.machineServiceReminderEnabled = true,
    this.reminderIntervalDays = 7,
    // Maintenance — routine cleaning
    this.routineCleaningReminderEnabled = true,
    this.cleaningFrequency = CleaningFrequency.daily,
    this.cleaningReminderTime = '08:00',
    this.cleaningNotifyOwner = true,
    this.cleaningNotifyManager = true,
    this.cleaningWhatsappNotification = true,
    this.cleaningInAppNotification = true,
    this.cleaningChecklist = const {},
    this.selectedReminderRecipientIds = const {},
    // WhatsApp reminder
    this.whatsappReminderEnabled = true,
    // System
    this.autoBackup = true,
    this.autoUpdate = true,
    // Order
    this.autoQueueNumber = true,
    this.autoPrintReceipt = true,
    this.sendReceiptToWhatsapp = true,
    // Customer
    this.yeloWalletEnabled = true,
    this.pointRewardEnabled = true,
    this.membershipEnabled = true,
    // Pickup & Delivery
    this.pickupEnabled = true,
    this.deliveryEnabled = true,
    this.showGoogleMaps = true,
    // Security
    this.whatsappOtpLogin = true,
    this.autoLogout = true,
    this.ownerPinForReports = true,
  });

  final bool soundOnNewOrder;
  final bool vibrateOnNewOrder;
  final bool showNewOrderPopup;

  final bool machineServiceReminderEnabled;
  final int reminderIntervalDays;

  final bool routineCleaningReminderEnabled;
  final CleaningFrequency cleaningFrequency;
  final String cleaningReminderTime;
  final bool cleaningNotifyOwner;
  final bool cleaningNotifyManager;
  final bool cleaningWhatsappNotification;
  final bool cleaningInAppNotification;
  final Map<String, bool> cleaningChecklist;

  final Set<String> selectedReminderRecipientIds;

  final bool whatsappReminderEnabled;

  final bool autoBackup;
  final bool autoUpdate;

  final bool autoQueueNumber;
  final bool autoPrintReceipt;
  final bool sendReceiptToWhatsapp;

  final bool yeloWalletEnabled;
  final bool pointRewardEnabled;
  final bool membershipEnabled;

  final bool pickupEnabled;
  final bool deliveryEnabled;
  final bool showGoogleMaps;

  final bool whatsappOtpLogin;
  final bool autoLogout;
  final bool ownerPinForReports;

  Map<String, bool> get resolvedCleaningChecklist {
    if (cleaningChecklist.isNotEmpty) return cleaningChecklist;
    return defaultCleaningChecklist();
  }

  Set<String> get resolvedSelectedReminderRecipientIds {
    if (selectedReminderRecipientIds.isNotEmpty) {
      return selectedReminderRecipientIds;
    }
    return defaultSelectedReminderRecipientIds();
  }

  AppSettingsState copyWith({
    bool? soundOnNewOrder,
    bool? vibrateOnNewOrder,
    bool? showNewOrderPopup,
    bool? machineServiceReminderEnabled,
    int? reminderIntervalDays,
    bool? routineCleaningReminderEnabled,
    CleaningFrequency? cleaningFrequency,
    String? cleaningReminderTime,
    bool? cleaningNotifyOwner,
    bool? cleaningNotifyManager,
    bool? cleaningWhatsappNotification,
    bool? cleaningInAppNotification,
    Map<String, bool>? cleaningChecklist,
    Set<String>? selectedReminderRecipientIds,
    bool? whatsappReminderEnabled,
    bool? autoBackup,
    bool? autoUpdate,
    bool? autoQueueNumber,
    bool? autoPrintReceipt,
    bool? sendReceiptToWhatsapp,
    bool? yeloWalletEnabled,
    bool? pointRewardEnabled,
    bool? membershipEnabled,
    bool? pickupEnabled,
    bool? deliveryEnabled,
    bool? showGoogleMaps,
    bool? whatsappOtpLogin,
    bool? autoLogout,
    bool? ownerPinForReports,
  }) {
    return AppSettingsState(
      soundOnNewOrder: soundOnNewOrder ?? this.soundOnNewOrder,
      vibrateOnNewOrder: vibrateOnNewOrder ?? this.vibrateOnNewOrder,
      showNewOrderPopup: showNewOrderPopup ?? this.showNewOrderPopup,
      machineServiceReminderEnabled:
          machineServiceReminderEnabled ?? this.machineServiceReminderEnabled,
      reminderIntervalDays: reminderIntervalDays ?? this.reminderIntervalDays,
      routineCleaningReminderEnabled: routineCleaningReminderEnabled ??
          this.routineCleaningReminderEnabled,
      cleaningFrequency: cleaningFrequency ?? this.cleaningFrequency,
      cleaningReminderTime: cleaningReminderTime ?? this.cleaningReminderTime,
      cleaningNotifyOwner: cleaningNotifyOwner ?? this.cleaningNotifyOwner,
      cleaningNotifyManager: cleaningNotifyManager ?? this.cleaningNotifyManager,
      cleaningWhatsappNotification:
          cleaningWhatsappNotification ?? this.cleaningWhatsappNotification,
      cleaningInAppNotification:
          cleaningInAppNotification ?? this.cleaningInAppNotification,
      cleaningChecklist: cleaningChecklist ?? this.cleaningChecklist,
      selectedReminderRecipientIds:
          selectedReminderRecipientIds ?? this.selectedReminderRecipientIds,
      whatsappReminderEnabled:
          whatsappReminderEnabled ?? this.whatsappReminderEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      autoQueueNumber: autoQueueNumber ?? this.autoQueueNumber,
      autoPrintReceipt: autoPrintReceipt ?? this.autoPrintReceipt,
      sendReceiptToWhatsapp:
          sendReceiptToWhatsapp ?? this.sendReceiptToWhatsapp,
      yeloWalletEnabled: yeloWalletEnabled ?? this.yeloWalletEnabled,
      pointRewardEnabled: pointRewardEnabled ?? this.pointRewardEnabled,
      membershipEnabled: membershipEnabled ?? this.membershipEnabled,
      pickupEnabled: pickupEnabled ?? this.pickupEnabled,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      showGoogleMaps: showGoogleMaps ?? this.showGoogleMaps,
      whatsappOtpLogin: whatsappOtpLogin ?? this.whatsappOtpLogin,
      autoLogout: autoLogout ?? this.autoLogout,
      ownerPinForReports: ownerPinForReports ?? this.ownerPinForReports,
    );
  }
}

const reminderIntervalOptions = [7, 14, 30, 90];

const whatsappReminderExamples = [
  'Jadwal Service Mesin',
  'Pergantian Filter',
  'Pergantian Oli Mesin',
  'Maintenance Dryer',
];

class AppAboutInfo {
  const AppAboutInfo({
    required this.appVersion,
    required this.databaseVersion,
    required this.buildNumber,
    required this.developer,
  });

  final String appVersion;
  final String databaseVersion;
  final String buildNumber;
  final String developer;
}

const defaultAppAboutInfo = AppAboutInfo(
  appVersion: '1.0.0',
  databaseVersion: '2026.08.01',
  buildNumber: '108',
  developer: 'Yelo Laundry Team',
);

const initialAppSettings = AppSettingsState();
