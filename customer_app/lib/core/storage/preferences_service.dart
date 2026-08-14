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
        if (session.birthDate != null)
          'birthDate': session.birthDate!.toIso8601String(),
        if (session.occupation != null) 'occupation': session.occupation,
        if (session.gender != null) 'gender': session.gender!.name,
        if (session.memberSerialNumber != null)
          'memberSerialNumber': session.memberSerialNumber,
        'loyaltyPoints': session.loyaltyPoints,
        'walletBalance': session.walletBalance,
        if (session.membershipLevel != null)
          'membershipLevel': session.membershipLevel!.label,
      }),
    );
  }

  Future<CustomerSession?> readCustomerProfile() async {
    final prefs = await _instance;
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return CustomerSession.fromJson(json);
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
