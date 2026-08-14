import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/utils/phone_util.dart';
import 'package:yelo_laundry_customer/features/auth/data/auth_repository.dart';

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<CustomerSession> uploadAvatar(String filePath) async {
    final data = await _api.uploadMultipart<Map<String, dynamic>>(
      '/auth/profile/avatar',
      fileField: 'avatar',
      filePath: filePath,
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerSession.fromJson(data);
  }

  Future<CustomerSession> updateProfile({
    required String fullName,
    DateTime? birthDate,
    String? occupation,
    String? photoUrl,
  }) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/auth/profile',
      data: {
        'fullName': fullName,
        if (birthDate != null) 'birthDate': _formatBirthDateForApi(birthDate),
        'occupation': ?occupation,
        'photoUrl': ?photoUrl,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerSession.fromJson(data);
  }

  Future<SendOtpResult> requestPhoneChange(String phone) async {
    final normalizedPhone = PhoneUtil.normalizeForApi(phone);
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/profile/phone/request',
      data: {'phone': normalizedPhone},
      parser: (json) => json as Map<String, dynamic>,
    );

    return SendOtpResult(
      otpRequestId: data['otpRequestId'] as String,
      expiresIn: data['expiresIn'] as int,
      maskedPhone: data['maskedPhone'] as String,
    );
  }

  Future<CustomerSession> verifyPhoneChange({
    required String phone,
    required String otpRequestId,
    required String otpCode,
  }) async {
    final normalizedPhone = PhoneUtil.normalizeForApi(phone);
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/profile/phone/verify',
      data: {
        'phone': normalizedPhone,
        'otpRequestId': otpRequestId,
        'otpCode': otpCode,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return CustomerSession.fromJson(data);
  }

  String _formatBirthDateForApi(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
