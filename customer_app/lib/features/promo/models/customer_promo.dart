class CustomerPromo {
  const CustomerPromo({
    required this.id,
    required this.title,
    required this.description,
    this.discountPercent,
    this.discountLabel,
    this.bannerUrl,
    this.minTransaction,
    this.maxDiscount,
    this.expiresAt,
    this.voucherCode,
    this.terms,
    this.isUsable = true,
    this.unusableReason,
  });

  final String id;
  final String title;
  final String description;
  final int? discountPercent;
  final String? discountLabel;
  final String? bannerUrl;
  final double? minTransaction;
  final double? maxDiscount;
  final DateTime? expiresAt;
  final String? voucherCode;
  final String? terms;
  final bool isUsable;
  final String? unusableReason;

  String? get badgePercentLabel {
    if (discountPercent == null) return null;
    return '$discountPercent%';
  }

  factory CustomerPromo.fromJson(Map<String, dynamic> json) {
    final discountPercent = (json['discountPercent'] as num?)?.round();
    final discountValue = (json['discountValue'] as num?)?.toDouble();
    final discountType = json['discountType'] as String?;

    return CustomerPromo(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountPercent: discountPercent ??
          (discountType == 'PERCENTAGE' && discountValue != null
              ? discountValue.round()
              : null),
      discountLabel: json['discountLabel'] as String? ?? json['benefit'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      minTransaction: (json['minTransaction'] as num?)?.toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      voucherCode: json['voucherCode'] as String? ?? json['code'] as String?,
      terms: json['terms'] as String? ?? json['termsAndConditions'] as String?,
      isUsable: json['isUsable'] as bool? ?? true,
      unusableReason: json['unusableReason'] as String?,
    );
  }
}
