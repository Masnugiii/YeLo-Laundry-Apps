import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/core/utils/phone_util.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      final message = error.message.toLowerCase();
      if (message.contains('already registered') ||
          message.contains('sudah terdaftar')) {
        return 'Nomor WhatsApp sudah digunakan akun lain.';
      }
      if (message.contains('different')) {
        return 'Nomor baru harus berbeda dari nomor saat ini.';
      }
      if (message.contains('invalid') || message.contains('tidak valid')) {
        return 'Nomor WhatsApp tidak valid.';
      }
      return error.message;
    }
    return 'Gagal mengirim kode verifikasi. Coba lagi.';
  }

  Future<void> _submit() async {
    final rawPhone = _phoneController.text.trim();
    final validationError = PhoneUtil.validate(rawPhone);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final phone = PhoneUtil.normalizeForApi(rawPhone);
    final currentPhone = ref.read(sessionProvider).phone.trim();

    if (phone == PhoneUtil.normalizeForApi(currentPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor baru harus berbeda dari nomor saat ini.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final result =
          await ref.read(profileRepositoryProvider).requestPhoneChange(phone);
      if (!mounted) return;

      context.push(
        '/otp?phone=${Uri.encodeComponent(phone)}'
        '&purpose=phone_change'
        '&otpRequestId=${Uri.encodeComponent(result.otpRequestId)}'
        '&maskedPhone=${Uri.encodeComponent(result.maskedPhone)}',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(error))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPhone = ref.watch(sessionProvider).phone.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Ganti Nomor HP'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              children: [
                PickupDashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor saat ini',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        currentPhone.isEmpty ? '-' : currentPhone,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Masukkan nomor WhatsApp baru. Kami akan mengirim kode verifikasi ke nomor tersebut.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _loading ? null : _submit(),
                        decoration: InputDecoration(
                          labelText: 'Nomor WhatsApp Baru',
                          hintText: '081234567890',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Kirim Kode Verifikasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
