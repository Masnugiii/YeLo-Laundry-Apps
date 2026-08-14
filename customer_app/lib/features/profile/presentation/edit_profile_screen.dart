import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/network/api_exception.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/customer_session.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/profile/data/customer_occupation_options.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _maxAvatarBytes = 10 * 1024 * 1024;
  static const _allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};
  static const _highlightColor = Color(0xFFF4E900);
  static const _saveButtonColor = Color(0xFFF6CF00);

  static final _birthDateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

  final _nameController = TextEditingController();
  final _otherOccupationController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _loading = false;
  bool _initialized = false;
  String? _pickedImagePath;
  DateTime? _birthDate;
  String? _selectedOccupation;

  @override
  void dispose() {
    _nameController.dispose();
    _otherOccupationController.dispose();
    super.dispose();
  }

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s8,
            AppSpacing.s8,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Edit Profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initialize(CustomerSession session) {
    if (_initialized) return;
    _nameController.text = session.fullName;
    _birthDate = session.birthDate;

    final occupation = session.occupation?.trim();
    if (occupation != null && occupation.isNotEmpty) {
      if (CustomerOccupationOptions.isPredefinedChoice(occupation)) {
        _selectedOccupation = occupation;
      } else {
        _selectedOccupation = CustomerOccupationOptions.other;
        _otherOccupationController.text = occupation;
      }
    }

    _initialized = true;
  }

  String? _resolveOccupationForSave() {
    final selected = _selectedOccupation;
    if (selected == null || selected.isEmpty) return null;

    if (selected == CustomerOccupationOptions.other) {
      final custom = _otherOccupationController.text.trim();
      return custom.isEmpty ? null : custom;
    }

    return selected;
  }

  Future<void> _selectOccupation() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s8,
                    AppSpacing.s16,
                    AppSpacing.s4,
                  ),
                  child: Text(
                    'Pilih Pekerjaan',
                    style: _poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: CustomerOccupationOptions.choices
                        .map(
                          (option) => ListTile(
                            title: Text(option),
                            trailing: _selectedOccupation == option
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.brandBlue,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, option),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedOccupation = selected;
        if (selected != CustomerOccupationOptions.other) {
          _otherOccupationController.clear();
        }
      });
    }
  }

  Widget _buildOccupationField() {
    final label = _selectedOccupation != null &&
            _selectedOccupation != CustomerOccupationOptions.other
        ? _selectedOccupation!
        : _selectedOccupation == CustomerOccupationOptions.other &&
                _otherOccupationController.text.trim().isNotEmpty
            ? _otherOccupationController.text.trim()
            : 'Pilih pekerjaan';

    return InkWell(
      onTap: _selectOccupation,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Pekerjaan Saat Ini?',
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.brandBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _poppins(
            fontSize: 14,
            color: _selectedOccupation != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandBlue,
              onPrimary: Colors.white,
              secondary: AppColors.accent,
              onSecondary: AppColors.brandBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Widget _buildBirthDateField() {
    final label = _birthDate != null
        ? _birthDateFormat.format(_birthDate!)
        : 'Pilih tanggal lahir';

    return InkWell(
      onTap: _selectBirthDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.brandBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _poppins(
            fontSize: 14,
            color: _birthDate != null
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _formatPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return trimmed;

    if (trimmed.startsWith('+62')) {
      final digits = trimmed.substring(3);
      if (digits.length >= 9) {
        return '+62 ${digits.substring(0, digits.length - 8)} ${digits.substring(digits.length - 8)}';
      }
    }

    return trimmed;
  }

  Widget _buildPhoneField(CustomerSession session) {
    final phone = session.phone.trim();
    final displayPhone = phone.isEmpty ? '-' : _formatPhone(phone);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Nomor Telepon',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        displayPhone,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _poppins(
          fontSize: 14,
          color: phone.isEmpty
              ? AppColors.textSecondary
              : AppColors.textPrimary,
        ),
      ),
    );
  }

  String _avatarInitial(CustomerSession session) {
    final name = session.fullName.trim();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return 'Y';
  }

  String? _validateImageFile(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1) {
      return 'Format foto tidak didukung.';
    }

    final extension = path.toLowerCase().substring(dotIndex);
    if (!_allowedExtensions.contains(extension)) {
      return 'Format foto tidak didukung.';
    }

    final size = File(path).lengthSync();
    if (size > _maxAvatarBytes) {
      return 'Ukuran foto terlalu besar.';
    }

    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      final validationError = _validateImageFile(picked.path);
      if (validationError != null) {
        _showError(validationError);
        return;
      }

      setState(() => _pickedImagePath = picked.path);
    } catch (_) {
      _showError('Gagal memilih foto. Silakan coba lagi.');
    }
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload Foto',
                  style: _poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.brandBlue,
                  ),
                  title: const Text('Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.brandBlue,
                  ),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPreview(CustomerSession session) {
    const radius = 52.0;
    final pickedPath = _pickedImagePath;
    final photoUrl = session.photoUrl?.trim();

    ImageProvider? imageProvider;
    if (pickedPath != null) {
      imageProvider = FileImage(File(pickedPath));
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      imageProvider = NetworkImage(photoUrl);
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: _highlightColor,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Text(
                    _avatarInitial(session),
                    style: _poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandBlue,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextButton(
          onPressed: _showImageSourceSheet,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Upload Foto',
            style: _poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.brandBlue,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    try {
      final repository = ref.read(profileRepositoryProvider);

      if (_pickedImagePath != null) {
        await repository.uploadAvatar(_pickedImagePath!);
      }

      await repository.updateProfile(
        fullName: _nameController.text.trim(),
        birthDate: _birthDate,
        occupation: _resolveOccupationForSave(),
      );

      await ref.read(authProvider.notifier).refreshProfile();

      if (mounted) context.pop();
    } on ApiException catch (error) {
      if (mounted) _showError(error.message);
    } catch (error) {
      if (mounted) _showError(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    _initialize(session);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildDashboardHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(child: _buildAvatarPreview(session)),
                const SizedBox(height: AppSpacing.s24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                const SizedBox(height: 12),
                _buildPhoneField(session),
                const SizedBox(height: 12),
                _buildBirthDateField(),
                const SizedBox(height: 12),
                _buildOccupationField(),
                if (_selectedOccupation == CustomerOccupationOptions.other) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otherOccupationController,
                    maxLength: 100,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Masukkan pekerjaan',
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: _saveButtonColor,
                    disabledBackgroundColor:
                        _saveButtonColor.withValues(alpha: 0.6),
                    foregroundColor: AppColors.brandBlue,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandBlue,
                          ),
                        )
                      : Text(
                          'Simpan',
                          style: _poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandBlue,
                          ),
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
