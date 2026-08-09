import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/system_settings_models.dart';
import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_async_scaffold.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';

class CompanySettingsScreen extends ConsumerStatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  ConsumerState<CompanySettingsScreen> createState() =>
      _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends ConsumerState<CompanySettingsScreen> {
  CompanySettings? _draft;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final settingsAsync = ref.watch(companySettingsProvider);

    return settingsAsync.when(
      loading: () => SettingsAsyncScaffold(
        title: 'Profil Perusahaan',
        isLoading: true,
        error: null,
        onRetry: () => ref.invalidate(companySettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => SettingsAsyncScaffold(
        title: 'Profil Perusahaan',
        isLoading: false,
        error: error,
        onRetry: () => ref.invalidate(companySettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      data: (settings) {
        final form = _draft ?? settings;
        return SettingsAsyncScaffold(
          title: 'Profil Perusahaan',
          isLoading: false,
          error: null,
          onRetry: () => ref.invalidate(companySettingsProvider),
          canEdit: canEdit,
          isSaving: _isSaving,
          onSave: canEdit ? () => _save(form) : null,
          child: Column(
            children: [
              _textField(
                key: 'companyName',
                label: 'Nama Perusahaan',
                value: form.companyName,
                enabled: canEdit,
                onChanged: (value) =>
                    setState(() => _draft = form.copyWith(companyName: value)),
              ),
              _textField(
                key: 'phone',
                label: 'Telepon',
                value: form.phone ?? '',
                enabled: canEdit,
                onChanged: (value) =>
                    setState(() => _draft = form.copyWith(phone: value)),
              ),
              _textField(
                key: 'email',
                label: 'Email',
                value: form.email ?? '',
                enabled: canEdit,
                onChanged: (value) =>
                    setState(() => _draft = form.copyWith(email: value)),
              ),
              _textField(
                key: 'businessHours',
                label: 'Jam Operasional',
                value: form.businessHours ?? '',
                enabled: canEdit,
                onChanged: (value) => setState(
                  () => _draft = form.copyWith(businessHours: value),
                ),
              ),
              _textField(
                key: 'timezone',
                label: 'Timezone',
                value: form.timezone ?? '',
                enabled: canEdit,
                onChanged: (value) =>
                    setState(() => _draft = form.copyWith(timezone: value)),
              ),
              _textField(
                key: 'currency',
                label: 'Mata Uang',
                value: form.currency ?? '',
                enabled: canEdit,
                onChanged: (value) =>
                    setState(() => _draft = form.copyWith(currency: value)),
              ),
              _textField(
                key: 'address',
                label: 'Alamat',
                value: form.address ?? '',
                enabled: canEdit,
                maxLines: 3,
                onChanged: (value) =>
                    setState(() => _draft = form.copyWith(address: value)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(CompanySettings form) async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .updateCompanySettings(form.toJson());
      ref.invalidate(companySettingsProvider);
      setState(() => _draft = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil perusahaan berhasil disimpan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan profil perusahaan.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _textField({
    required String key,
    required String label,
    required String value,
    required bool enabled,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: TextFormField(
        key: ValueKey('$key-$value'),
        initialValue: value,
        enabled: enabled,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: SettingsTheme.textFieldDecoration.copyWith(labelText: label),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }
}
