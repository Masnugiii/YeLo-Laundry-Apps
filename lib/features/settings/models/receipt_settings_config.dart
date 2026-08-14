class ReceiptSettingsConfig {
  const ReceiptSettingsConfig({
    required this.showLogo,
    required this.showQRCode,
    this.footerText,
    required this.companyName,
    this.companyPhone,
    this.companyAddress,
    this.companyLogoUrl,
  });

  final bool showLogo;
  final bool showQRCode;
  final String? footerText;
  final String companyName;
  final String? companyPhone;
  final String? companyAddress;
  final String? companyLogoUrl;

  factory ReceiptSettingsConfig.fromJson(Map<String, dynamic> json) {
    return ReceiptSettingsConfig(
      showLogo: json['showLogo'] as bool? ?? true,
      showQRCode: json['showQRCode'] as bool? ?? false,
      footerText: json['footerText'] as String?,
      companyName: json['companyName'] as String? ?? '',
      companyPhone: json['companyPhone'] as String?,
      companyAddress: json['companyAddress'] as String?,
      companyLogoUrl: json['companyLogoUrl'] as String?,
    );
  }

  Map<String, dynamic> toUpdatePayload({
    bool? showLogo,
    bool? showQRCode,
    String? footerText,
  }) {
    return {
      'showLogo': ?showLogo,
      'showQRCode': ?showQRCode,
      'footerText': ?footerText,
    };
  }
}

class QueueNumberingConfig {
  const QueueNumberingConfig({
    required this.prefix,
    required this.startingNumber,
    required this.dailyReset,
  });

  final String prefix;
  final int startingNumber;
  final bool dailyReset;

  String get formattedNextQueueNumber =>
      '$prefix-${startingNumber.toString().padLeft(4, '0')}';

  factory QueueNumberingConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const QueueNumberingConfig(
        prefix: 'A',
        startingNumber: 1,
        dailyReset: true,
      );
    }

    return QueueNumberingConfig(
      prefix: json['prefix'] as String? ?? 'A',
      startingNumber: (json['startingNumber'] as num?)?.toInt() ?? 1,
      dailyReset: json['dailyReset'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'queue': {
        'prefix': prefix,
        'startingNumber': startingNumber,
        'dailyReset': dailyReset,
      },
    };
  }
}
