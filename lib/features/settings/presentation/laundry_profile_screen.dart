import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_shadows.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/data/dummy_laundry_profile.dart';
import 'package:yelo_laundry_erp/features/settings/models/laundry_profile.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';

class LaundryProfileScreen extends StatefulWidget {
  const LaundryProfileScreen({super.key});

  @override
  State<LaundryProfileScreen> createState() => _LaundryProfileScreenState();
}

class _LaundryProfileScreenState extends State<LaundryProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _instagramController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    final profile = getLaundryProfile();
    _nameController = TextEditingController(text: profile.name);
    _addressController = TextEditingController(text: profile.address);
    _cityController = TextEditingController(text: profile.city);
    _whatsappController = TextEditingController(text: profile.whatsapp);
    _instagramController = TextEditingController(text: profile.instagram);
    _websiteController = TextEditingController(text: profile.website);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _onSave() {
    saveLaundryProfile(
      LaundryProfile(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        instagram: _instagramController.text.trim(),
        website: _websiteController.text.trim(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Profil laundry berhasil disimpan.',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        title: Text(
          'Profil Laundry',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s20,
                AppSpacing.s32,
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.md(),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        getLaundryProfile().logoAsset,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      _field('Nama Laundry', _nameController),
                      const SizedBox(height: AppSpacing.s16),
                      _field('Alamat Laundry', _addressController, maxLines: 2),
                      const SizedBox(height: AppSpacing.s16),
                      _field('Kota', _cityController),
                      const SizedBox(height: AppSpacing.s16),
                      _field('Nomor WhatsApp', _whatsappController),
                      const SizedBox(height: AppSpacing.s16),
                      _field('Instagram', _instagramController),
                      const SizedBox(height: AppSpacing.s16),
                      _field('Website', _websiteController),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s12,
              AppSpacing.s20,
              AppSpacing.s24,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Simpan Profil',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: SettingsTheme.textFieldDecoration,
        ),
      ],
    );
  }
}
