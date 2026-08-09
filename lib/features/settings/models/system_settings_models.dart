class CompanySettings {
  const CompanySettings({
    this.id,
    required this.companyName,
    this.phone,
    this.email,
    this.address,
    this.logoUrl,
    this.businessHours,
    this.timezone,
    this.currency,
    this.taxRate,
  });

  final String? id;
  final String companyName;
  final String? phone;
  final String? email;
  final String? address;
  final String? logoUrl;
  final String? businessHours;
  final String? timezone;
  final String? currency;
  final double? taxRate;

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'] as String?,
      companyName: json['companyName'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      businessHours: json['businessHours'] as String?,
      timezone: json['timezone'] as String?,
      currency: json['currency'] as String?,
      taxRate: (json['taxRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'companyName': companyName,
        'phone': phone,
        'email': email,
        'address': address,
        'logoUrl': logoUrl,
        'businessHours': businessHours,
        'timezone': timezone,
        'currency': currency,
        'taxRate': taxRate,
      };

  CompanySettings copyWith({
    String? companyName,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
    String? businessHours,
    String? timezone,
    String? currency,
    double? taxRate,
  }) {
    return CompanySettings(
      id: id,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      businessHours: businessHours ?? this.businessHours,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}

class AttendanceGpsConfig {
  const AttendanceGpsConfig({
    required this.officeLatitude,
    required this.officeLongitude,
    required this.officeRadiusMeters,
  });

  final double officeLatitude;
  final double officeLongitude;
  final double officeRadiusMeters;

  factory AttendanceGpsConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceGpsConfig(
      officeLatitude: (json['officeLatitude'] as num).toDouble(),
      officeLongitude: (json['officeLongitude'] as num).toDouble(),
      officeRadiusMeters: (json['officeRadiusMeters'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'officeLatitude': officeLatitude,
        'officeLongitude': officeLongitude,
        'officeRadiusMeters': officeRadiusMeters,
      };
}

class AttendanceSettingsConfig {
  const AttendanceSettingsConfig({
    this.id,
    required this.workStartTime,
    required this.workEndTime,
    required this.lateToleranceMinutes,
    required this.overtimeEnabled,
    this.gps,
    required this.shiftCount,
  });

  final String? id;
  final String workStartTime;
  final String workEndTime;
  final int lateToleranceMinutes;
  final bool overtimeEnabled;
  final AttendanceGpsConfig? gps;
  final int shiftCount;

  factory AttendanceSettingsConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceSettingsConfig(
      id: json['id'] as String?,
      workStartTime: json['workStartTime'] as String? ?? '08:00',
      workEndTime: json['workEndTime'] as String? ?? '17:00',
      lateToleranceMinutes: json['lateToleranceMinutes'] as int? ?? 0,
      overtimeEnabled: json['overtimeEnabled'] as bool? ?? false,
      gps: json['gps'] != null
          ? AttendanceGpsConfig.fromJson(json['gps'] as Map<String, dynamic>)
          : null,
      shiftCount: json['shiftCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'workStartTime': workStartTime,
        'workEndTime': workEndTime,
        'lateToleranceMinutes': lateToleranceMinutes,
        'overtimeEnabled': overtimeEnabled,
        if (gps != null) 'gps': gps!.toJson(),
      };
}

class DocumentRulesConfig {
  const DocumentRulesConfig({
    required this.maxFileSizeBytes,
    required this.allowedMimeTypes,
    required this.compressionMode,
    required this.ocrEnabled,
  });

  final int maxFileSizeBytes;
  final List<String> allowedMimeTypes;
  final String compressionMode;
  final bool ocrEnabled;

  factory DocumentRulesConfig.fromJson(Map<String, dynamic> json) {
    return DocumentRulesConfig(
      maxFileSizeBytes: json['maxFileSizeBytes'] as int? ?? 10485760,
      allowedMimeTypes: (json['allowedMimeTypes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      compressionMode: json['compressionMode'] as String? ?? 'original',
      ocrEnabled: json['ocrEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'maxFileSizeBytes': maxFileSizeBytes,
        'allowedMimeTypes': allowedMimeTypes,
        'compressionMode': compressionMode,
        'ocrEnabled': ocrEnabled,
      };

  DocumentRulesConfig copyWith({
    int? maxFileSizeBytes,
    List<String>? allowedMimeTypes,
    String? compressionMode,
    bool? ocrEnabled,
  }) {
    return DocumentRulesConfig(
      maxFileSizeBytes: maxFileSizeBytes ?? this.maxFileSizeBytes,
      allowedMimeTypes: allowedMimeTypes ?? this.allowedMimeTypes,
      compressionMode: compressionMode ?? this.compressionMode,
      ocrEnabled: ocrEnabled ?? this.ocrEnabled,
    );
  }
}

class BackupSettingsConfig {
  const BackupSettingsConfig({
    required this.enabled,
    required this.schedule,
    required this.retentionDays,
  });

  final bool enabled;
  final String schedule;
  final int retentionDays;

  factory BackupSettingsConfig.fromJson(Map<String, dynamic> json) {
    return BackupSettingsConfig(
      enabled: json['enabled'] as bool? ?? false,
      schedule: json['schedule'] as String? ?? 'daily',
      retentionDays: json['retentionDays'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'schedule': schedule,
        'retentionDays': retentionDays,
      };

  BackupSettingsConfig copyWith({
    bool? enabled,
    String? schedule,
    int? retentionDays,
  }) {
    return BackupSettingsConfig(
      enabled: enabled ?? this.enabled,
      schedule: schedule ?? this.schedule,
      retentionDays: retentionDays ?? this.retentionDays,
    );
  }
}

class NotificationToggleConfig {
  const NotificationToggleConfig({
    required this.notifyNewOrder,
    required this.notifyPayment,
    required this.notifyIroningFinished,
    required this.notifyPickupDelivery,
    required this.notifyWallet,
  });

  final bool notifyNewOrder;
  final bool notifyPayment;
  final bool notifyIroningFinished;
  final bool notifyPickupDelivery;
  final bool notifyWallet;

  factory NotificationToggleConfig.fromJson(Map<String, dynamic> json) {
    return NotificationToggleConfig(
      notifyNewOrder: json['notify_new_order'] as bool? ?? true,
      notifyPayment: json['notify_payment'] as bool? ?? true,
      notifyIroningFinished: json['notify_ironing_finished'] as bool? ?? true,
      notifyPickupDelivery: json['notify_pickup_delivery'] as bool? ?? true,
      notifyWallet: json['notify_wallet'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'notify_new_order': notifyNewOrder,
        'notify_payment': notifyPayment,
        'notify_ironing_finished': notifyIroningFinished,
        'notify_pickup_delivery': notifyPickupDelivery,
        'notify_wallet': notifyWallet,
      };

  NotificationToggleConfig copyWith({
    bool? notifyNewOrder,
    bool? notifyPayment,
    bool? notifyIroningFinished,
    bool? notifyPickupDelivery,
    bool? notifyWallet,
  }) {
    return NotificationToggleConfig(
      notifyNewOrder: notifyNewOrder ?? this.notifyNewOrder,
      notifyPayment: notifyPayment ?? this.notifyPayment,
      notifyIroningFinished:
          notifyIroningFinished ?? this.notifyIroningFinished,
      notifyPickupDelivery: notifyPickupDelivery ?? this.notifyPickupDelivery,
      notifyWallet: notifyWallet ?? this.notifyWallet,
    );
  }
}

class NotificationTemplateConfig {
  const NotificationTemplateConfig({
    required this.id,
    required this.code,
    required this.title,
    required this.body,
    required this.isActive,
  });

  final String id;
  final String code;
  final String title;
  final String body;
  final bool isActive;

  factory NotificationTemplateConfig.fromJson(Map<String, dynamic> json) {
    return NotificationTemplateConfig(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class NotificationSettingsConfig {
  const NotificationSettingsConfig({
    required this.settings,
    required this.templates,
  });

  final NotificationToggleConfig settings;
  final List<NotificationTemplateConfig> templates;

  factory NotificationSettingsConfig.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsConfig(
      settings: NotificationToggleConfig.fromJson(
        json['settings'] as Map<String, dynamic>? ?? const {},
      ),
      templates: (json['templates'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                NotificationTemplateConfig.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  NotificationSettingsConfig copyWith({
    NotificationToggleConfig? settings,
    List<NotificationTemplateConfig>? templates,
  }) {
    return NotificationSettingsConfig(
      settings: settings ?? this.settings,
      templates: templates ?? this.templates,
    );
  }
}

class DeliverySettingsConfig {
  const DeliverySettingsConfig({
    required this.status,
    this.message,
  });

  final String status;
  final String? message;

  factory DeliverySettingsConfig.fromJson(Map<String, dynamic> json) {
    return DeliverySettingsConfig(
      status: json['status'] as String? ?? 'not_configured',
      message: json['message'] as String?,
    );
  }

  bool get isNotConfigured => status == 'not_configured';
}
