class CustomerSession {
  const CustomerSession({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.photoUrl,
    this.loyaltyPoints = 0,
    this.walletBalance = 0,
  });

  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? photoUrl;
  final int loyaltyPoints;
  final double walletBalance;

  static const guest = CustomerSession(
    id: '',
    fullName: '',
    phone: '',
  );

  bool get isAuthenticated => id.isNotEmpty;

  CustomerSession copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? photoUrl,
    int? loyaltyPoints,
    double? walletBalance,
  }) {
    return CustomerSession(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}
