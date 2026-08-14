import 'package:flutter_test/flutter_test.dart';

import 'package:yelo_laundry_customer/core/network/api_client.dart';
import 'package:yelo_laundry_customer/core/storage/secure_storage_service.dart';
import 'package:yelo_laundry_customer/core/utils/phone_util.dart';
import 'package:yelo_laundry_customer/features/profile/data/profile_repository.dart';

class _PhoneChangeApiClient extends ApiClient {
  _PhoneChangeApiClient({required super.secureStorage});

  String? lastPath;
  Map<String, dynamic>? lastData;

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    lastPath = path;
    lastData = (data as Map<String, dynamic>?) ?? {};

    if (parser == null) {
      throw UnimplementedError('parser required');
    }

    if (path == '/auth/profile/phone/request') {
      return parser({
        'otpRequestId': 'otp-request-1',
        'expiresIn': 300,
        'maskedPhone': '+62812****7891',
      });
    }

    if (path == '/auth/profile/phone/verify') {
      return parser({
        'id': 'cust-1',
        'customerCode': 'CUS-0004827',
        'fullName': 'Test User',
        'phone': lastData?['phone'],
        'loyaltyPoints': 10,
        'walletBalance': 0,
      });
    }

    throw UnimplementedError('Unexpected POST $path');
  }
}

void main() {
  group('ProfileRepository phone change', () {
    late _PhoneChangeApiClient api;
    late ProfileRepository repository;

    setUp(() {
      api = _PhoneChangeApiClient(secureStorage: SecureStorageService());
      repository = ProfileRepository(apiClient: api);
    });

    test('requestPhoneChange normalizes phone and calls request endpoint', () async {
      final result = await repository.requestPhoneChange('081234567891');

      expect(api.lastPath, '/auth/profile/phone/request');
      expect(
        api.lastData?['phone'],
        PhoneUtil.normalizeForApi('081234567891'),
      );
      expect(result.otpRequestId, 'otp-request-1');
    });

    test('verifyPhoneChange sends required payload fields', () async {
      final session = await repository.verifyPhoneChange(
        phone: '081234567891',
        otpRequestId: 'otp-request-1',
        otpCode: '123456',
      );

      expect(api.lastPath, '/auth/profile/phone/verify');
      expect(api.lastData?['otpRequestId'], 'otp-request-1');
      expect(api.lastData?['otpCode'], '123456');
      expect(
        session.phone,
        PhoneUtil.normalizeForApi('081234567891'),
      );
      expect(session.memberSerialNumber, isNotNull);
    });
  });
}
