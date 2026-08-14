import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:yelo_laundry_customer/core/auth/auth_debug_log.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
            );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  String? _memoryAccessToken;
  String? _memoryRefreshToken;

  Future<String?> getAccessToken() async {
    if (_hasValue(_memoryAccessToken)) {
      return _memoryAccessToken;
    }

    final stored = await _storage.read(key: _accessTokenKey);
    if (_hasValue(stored)) {
      _memoryAccessToken = stored;
    }
    return stored;
  }

  Future<String?> getRefreshToken() async {
    if (_hasValue(_memoryRefreshToken)) {
      return _memoryRefreshToken;
    }

    final stored = await _storage.read(key: _refreshTokenKey);
    if (_hasValue(stored)) {
      _memoryRefreshToken = stored;
    }
    return stored;
  }

  Future<void> saveAccessToken(String token) async {
    _memoryAccessToken = token;
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    _memoryRefreshToken = token;
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    authDebugLog('saving access token: true');
    authDebugLog(
      'saving refresh token: ${refreshToken != null && refreshToken.isNotEmpty}',
    );

    _memoryAccessToken = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _memoryRefreshToken = refreshToken;
    }

    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } else {
      authDebugLog('refresh token returned: false');
    }

    authDebugLog('tokens saved');
    await _logPersistedTokens();
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    final refresh = await getRefreshToken();
    return _hasValue(access) || _hasValue(refresh);
  }

  Future<void> clearTokens() async {
    authDebugLog('clearing tokens');
    _memoryAccessToken = null;
    _memoryRefreshToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> _logPersistedTokens() async {
    final savedAccess = await getAccessToken();
    final savedRefresh = await getRefreshToken();
    authDebugLog(
      'access token persisted: ${_hasValue(savedAccess)}',
    );
    authDebugLog(
      'refresh token persisted: ${_hasValue(savedRefresh)}',
    );
  }

  bool _hasValue(String? value) => value != null && value.isNotEmpty;
}
