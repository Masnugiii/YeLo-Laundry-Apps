import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/storage/preferences_service.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
    required PreferencesService preferences,
  })  : _api = apiClient,
        _secureStorage = secureStorage,
        _preferences = preferences;

  final ApiClient _api;
  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  Future<SendOtpResult> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/otp/send',
      data: {'phone': phone, 'purpose': purpose},
      parser: (json) => json as Map<String, dynamic>,
    );

    return SendOtpResult(
      otpRequestId: data['otpRequestId'] as String,
      expiresIn: data['expiresIn'] as int,
      maskedPhone: data['maskedPhone'] as String,
    );
  }

  Future<CustomerSession> verifyOtp({
    required String otpRequestId,
    required String phone,
    required String otpCode,
    bool rememberMe = true,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {
        'otpRequestId': otpRequestId,
        'phone': phone,
        'otpCode': otpCode,
        'deviceInfo': 'Yelo Customer App',
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return _persistAuth(data, rememberMe: rememberMe);
  }

  Future<CustomerSession> register({
    required String otpRequestId,
    required String phone,
    required String otpCode,
    required String fullName,
    String? email,
    bool rememberMe = true,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/customer/register',
      data: {
        'otpRequestId': otpRequestId,
        'phone': phone,
        'otpCode': otpCode,
        'fullName': fullName,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return _persistAuth(data, rememberMe: rememberMe);
  }

  Future<CustomerSession?> restoreSession() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      return fetchProfile();
    } catch (_) {
      await _secureStorage.clearTokens();
      return null;
    }
  }

  Future<CustomerSession> fetchProfile() async {
    final data = await _api.get<Map<String, dynamic>>(
      '/auth/profile',
      parser: (json) => json as Map<String, dynamic>,
    );

    final session = CustomerSession(
      id: data['id'] as String,
      fullName: data['fullName'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      loyaltyPoints: (data['loyaltyPoints'] as num?)?.toInt() ?? 0,
      walletBalance: (data['walletBalance'] as num?)?.toDouble() ?? 0,
    );

    await _preferences.saveCustomerProfile(session);
    return session;
  }

  Future<void> logout() async {
    try {
      await _api.post<void>('/auth/logout');
    } catch (_) {}
    await _secureStorage.clearTokens();
    await _preferences.clearCustomerProfile();
  }

  Future<CustomerSession> _persistAuth(
    Map<String, dynamic> data, {
    required bool rememberMe,
  }) async {
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String?;
    final user = data['user'] as Map<String, dynamic>;

    if (rememberMe) {
      await _secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    final session = CustomerSession(
      id: user['id'] as String,
      fullName: user['fullName'] as String,
      phone: user['phone'] as String,
      email: user['email'] as String?,
      photoUrl: user['photoUrl'] as String?,
    );

    await _preferences.saveCustomerProfile(session);
    return session;
  }
}

class SendOtpResult {
  const SendOtpResult({
    required this.otpRequestId,
    required this.expiresIn,
    required this.maskedPhone,
  });

  final String otpRequestId;
  final int expiresIn;
  final String maskedPhone;
}
