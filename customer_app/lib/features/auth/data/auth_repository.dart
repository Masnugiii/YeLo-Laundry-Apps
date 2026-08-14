import 'package:yelo_laundry_customer/core/auth/auth_debug_log.dart';
import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/storage/preferences_service.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_customer/core/utils/phone_util.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required this._secureStorage,
    required this._preferences,
  })  : _api = apiClient;

  final ApiClient _api;
  final SecureStorageService _secureStorage;
  final PreferencesService _preferences;

  Future<SendOtpResult> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    final normalizedPhone = PhoneUtil.normalizeForApi(phone);
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/otp/send',
      data: {'phone': normalizedPhone, 'purpose': purpose},
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
    final normalizedPhone = PhoneUtil.normalizeForApi(phone);
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {
        'otpRequestId': otpRequestId,
        'phone': normalizedPhone,
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
    required int age,
    required String occupation,
    String? email,
    bool rememberMe = true,
  }) async {
    final normalizedPhone = PhoneUtil.normalizeForApi(phone);
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/customer/register',
      data: {
        'otpRequestId': otpRequestId,
        'phone': normalizedPhone,
        'otpCode': otpCode,
        'fullName': fullName,
        'age': age,
        'occupation': occupation,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      parser: (json) => json as Map<String, dynamic>,
    );

    return _persistAuth(data, rememberMe: rememberMe);
  }

  Future<CustomerSession?> restoreSession() async {
    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();

    authDebugLog(
      'restoreSession found access token: ${accessToken != null && accessToken.isNotEmpty}',
    );
    authDebugLog(
      'restoreSession found refresh token: ${refreshToken != null && refreshToken.isNotEmpty}',
    );

    if ((accessToken == null || accessToken.isEmpty) &&
        (refreshToken == null || refreshToken.isEmpty)) {
      return null;
    }

    try {
      return await fetchProfile();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        authDebugLog('restoreSession unauthorized');
        return null;
      }

      authDebugLog('restoreSession transient error, using cached profile');
      return _readCachedProfileIfTokensPresent();
    } catch (_) {
      authDebugLog('restoreSession error, using cached profile');
      return _readCachedProfileIfTokensPresent();
    }
  }

  Future<CustomerSession?> _readCachedProfileIfTokensPresent() async {
    if (!await _secureStorage.hasTokens()) return null;
    return _preferences.readCustomerProfile();
  }

  Future<CustomerSession> fetchProfile() async {
    final data = await _api.get<Map<String, dynamic>>(
      '/auth/profile',
      parser: (json) => json as Map<String, dynamic>,
    );

    final session = CustomerSession.fromJson(data);

    await _preferences.saveCustomerProfile(session);
    return session;
  }

  Future<void> logout() async {
    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        await _api.post<void>('/auth/logout');
      } catch (_) {
        // Best-effort server logout; local session is always cleared below.
      }
    }

    await _secureStorage.clearTokens();
    await _preferences.clearCustomerProfile();
  }

  Future<CustomerSession> _persistAuth(
    Map<String, dynamic> data, {
    required bool rememberMe,
  }) async {
    authDebugLog('login response received');

    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String?;
    final user = data['user'] as Map<String, dynamic>;

    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final hasTokens = await _secureStorage.hasTokens();
    if (!hasTokens) {
      authDebugLog('token persistence verification failed');
      throw const ApiException(
        message: 'Gagal menyimpan token autentikasi.',
        type: ApiErrorType.unknown,
      );
    }

    // OTP/register responses only include a minimal user object (no customerCode).
    // Load the full profile so member card serial + QR have real data immediately.
    authDebugLog('fetching profile after auth');
    try {
      return await fetchProfile();
    } on ApiException {
      rethrow;
    } catch (_) {
      final session = CustomerSession.fromJson({
        ...user,
        if (data['loyaltyPoints'] != null)
          'loyaltyPoints': data['loyaltyPoints'],
        if (data['walletBalance'] != null)
          'walletBalance': data['walletBalance'],
        if (data['membership'] != null) 'membership': data['membership'],
        if (data['membershipLevel'] != null)
          'membershipLevel': data['membershipLevel'],
      });

      await _preferences.saveCustomerProfile(session);
      return session;
    }
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
