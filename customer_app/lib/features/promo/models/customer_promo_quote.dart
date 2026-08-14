class CustomerPromoQuote {
  const CustomerPromoQuote({
    required this.promoId,
    required this.voucherCode,
    required this.subtotal,
    required this.discountPercent,
    required this.discountAmount,
    required this.total,
    this.maxDiscount,
  });

  final String promoId;
  final String voucherCode;
  final double subtotal;
  final int? discountPercent;
  final double discountAmount;
  final double total;
  final double? maxDiscount;

  factory CustomerPromoQuote.fromJson(Map<String, dynamic> json) {
    return CustomerPromoQuote(
      promoId: json['promoId'] as String,
      voucherCode: json['voucherCode'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.round(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
    );
  }
}
