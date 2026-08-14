class QrisPaymentConfig {
  const QrisPaymentConfig({
    required this.isActive,
    this.qrImageUrl,
    this.qrPayload,
    this.instructions = '',
  });

  final bool isActive;
  final String? qrImageUrl;
  final String? qrPayload;
  final String instructions;

  bool get isConfigured =>
      isActive &&
      ((qrImageUrl?.trim().isNotEmpty ?? false) ||
          (qrPayload?.trim().isNotEmpty ?? false));

  factory QrisPaymentConfig.fromJson(Map<String, dynamic> json) {
    return QrisPaymentConfig(
      isActive: json['isActive'] as bool? ?? false,
      qrImageUrl: json['qrImageUrl'] as String?,
      qrPayload: json['qrPayload'] as String?,
      instructions: json['instructions'] as String? ?? '',
    );
  }
}

class BankTransferPaymentConfig {
  const BankTransferPaymentConfig({
    required this.isActive,
    this.bankName = '',
    this.accountNumber = '',
    this.accountHolder = '',
    this.instructions = '',
  });

  final bool isActive;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final String instructions;

  bool get isConfigured =>
      isActive &&
      bankName.trim().isNotEmpty &&
      accountNumber.trim().isNotEmpty &&
      accountHolder.trim().isNotEmpty;

  String get displayLabel =>
      '$bankName • $accountNumber • a/n $accountHolder';

  factory BankTransferPaymentConfig.fromJson(Map<String, dynamic> json) {
    return BankTransferPaymentConfig(
      isActive: json['isActive'] as bool? ?? false,
      bankName: json['bankName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountHolder: json['accountHolder'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
    );
  }
}

class PaymentMethodAvailability {
  const PaymentMethodAvailability({
    required this.code,
    required this.name,
    required this.isActive,
  });

  final String code;
  final String name;
  final bool isActive;

  factory PaymentMethodAvailability.fromJson(Map<String, dynamic> json) {
    return PaymentMethodAvailability(
      code: json['code'] as String,
      name: json['name'] as String? ?? json['code'] as String,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class CustomerPaymentConfig {
  const CustomerPaymentConfig({
    required this.methods,
    required this.qris,
    required this.bankTransfer,
  });

  final List<PaymentMethodAvailability> methods;
  final QrisPaymentConfig qris;
  final BankTransferPaymentConfig bankTransfer;

  static const empty = CustomerPaymentConfig(
    methods: [],
    qris: QrisPaymentConfig(isActive: false),
    bankTransfer: BankTransferPaymentConfig(isActive: false),
  );

  bool isMethodAvailable(String code) {
    for (final method in methods) {
      if (method.code == code) return method.isActive;
    }
    return false;
  }

  List<String> get availableMethodCodes => methods
      .where((method) => method.isActive)
      .map((method) => method.code)
      .toList();

  factory CustomerPaymentConfig.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentConfig(
      methods: (json['methods'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                PaymentMethodAvailability.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      qris: QrisPaymentConfig.fromJson(
        json['qris'] as Map<String, dynamic>? ?? const {},
      ),
      bankTransfer: BankTransferPaymentConfig.fromJson(
        json['bankTransfer'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
