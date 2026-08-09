import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:yelo_laundry_customer/core/session/customer_session.dart';

class PreferencesService {
  PreferencesService([SharedPreferences? prefs]) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const _profileKey = 'customer_profile';
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language_code';
  static const _onboardingKey = 'onboarding_complete';
  static const _rememberMeKey = 'remember_me';

  Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveCustomerProfile(CustomerSession session) async {
    final prefs = await _instance;
    await prefs.setString(
      _profileKey,
      jsonEncode({
        'id': session.id,
        'fullName': session.fullName,
        'phone': session.phone,
        'email': session.email,
        'photoUrl': session.photoUrl,
        'loyaltyPoints': session.loyaltyPoints,
        'walletBalance': session.walletBalance,
      }),
    );
  }

  Future<CustomerSession?> readCustomerProfile() async {
    final prefs = await _instance;
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CustomerSession(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> clearCustomerProfile() async {
    final prefs = await _instance;
    await prefs.remove(_profileKey);
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _instance;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await _instance;
    return prefs.getBool(_rememberMeKey) ?? true;
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await _instance;
    await prefs.setString(_themeKey, mode);
  }

  Future<String?> readThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_themeKey);
  }

  Future<void> saveLanguageCode(String code) async {
    final prefs = await _instance;
    await prefs.setString(_languageKey, code);
  }

  Future<String?> readLanguageCode() async {
    final prefs = await _instance;
    return prefs.getString(_languageKey);
  }
}
