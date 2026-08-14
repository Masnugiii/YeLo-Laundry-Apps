import 'package:yelo_laundry_customer/core/membership/membership_level.dart';
import 'package:yelo_laundry_customer/core/membership/member_serial_number.dart';
import 'package:yelo_laundry_customer/core/session/customer_gender.dart';

class CustomerSession {
  const CustomerSession({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.photoUrl,
    this.gender,
    this.birthDate,
    this.occupation,
    this.memberSerialNumber,
    this.loyaltyPoints = 0,
    this.walletBalance = 0,
    this.membershipLevel,
  });

  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? photoUrl;
  final CustomerGender? gender;
  final DateTime? birthDate;
  final String? occupation;
  final String? memberSerialNumber;
  final int loyaltyPoints;
  final double walletBalance;
  final MembershipLevel? membershipLevel;

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
    CustomerGender? gender,
    DateTime? birthDate,
    String? occupation,
    String? memberSerialNumber,
    int? loyaltyPoints,
    double? walletBalance,
    MembershipLevel? membershipLevel,
  }) {
    return CustomerSession(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      occupation: occupation ?? this.occupation,
      memberSerialNumber: memberSerialNumber ?? this.memberSerialNumber,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      membershipLevel: membershipLevel ?? this.membershipLevel,
    );
  }

  factory CustomerSession.fromJson(Map<String, dynamic> json) {
    return CustomerSession(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      gender: CustomerGender.tryParse(json['gender'] as String?),
      birthDate: _parseBirthDate(json['birthDate']),
      occupation: json['occupation'] as String?,
      memberSerialNumber: MemberSerialNumber.parseFromJson(json),
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      membershipLevel: MembershipLevel.fromJson(json),
    );
  }

  static DateTime? _parseBirthDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isEmpty) return null;
    return DateTime.tryParse(raw as String)?.toLocal();
  }
}
