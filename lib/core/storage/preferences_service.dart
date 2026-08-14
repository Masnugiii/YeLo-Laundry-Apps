import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:yelo_laundry_erp/core/session/app_user_session.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  static const _profileKey = 'user_profile';
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language_code';
  static const _receiptPrinterKey = 'receipt_printer_name';
  static const _receiptPaperSizeKey = 'receipt_paper_size';

  final SharedPreferences _prefs;

  Future<void> saveProfile(AppUserSession session) async {
    await _prefs.setString(
      _profileKey,
      jsonEncode(session.toJson()),
    );
  }

  AppUserSession? readProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) {
      return null;
    }

    return AppUserSession.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clearProfile() => _prefs.remove(_profileKey);

  Future<void> saveThemeMode(String mode) => _prefs.setString(_themeKey, mode);

  String? readThemeMode() => _prefs.getString(_themeKey);

  Future<void> saveLanguageCode(String code) =>
      _prefs.setString(_languageKey, code);

  String? readLanguageCode() => _prefs.getString(_languageKey);

  Future<void> saveReceiptPrinterName(String name) =>
      _prefs.setString(_receiptPrinterKey, name);

  String? readReceiptPrinterName() => _prefs.getString(_receiptPrinterKey);

  Future<void> saveReceiptPaperSize(String size) =>
      _prefs.setString(_receiptPaperSizeKey, size);

  String? readReceiptPaperSize() => _prefs.getString(_receiptPaperSizeKey);
}
