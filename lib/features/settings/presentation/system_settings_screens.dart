import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/core/providers/core_providers.dart';
import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/settings/models/system_settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/settings_theme.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_async_scaffold.dart';
import 'package:yelo_laundry_erp/features/settings/providers/settings_provider.dart';

class AttendanceSettingsScreen extends ConsumerStatefulWidget {
  const AttendanceSettingsScreen({super.key});

  @override
  ConsumerState<AttendanceSettingsScreen> createState() =>
      _AttendanceSettingsScreenState();
}

class _AttendanceSettingsScreenState
    extends ConsumerState<AttendanceSettingsScreen> {
  AttendanceSettingsConfig? _draft;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final settingsAsync = ref.watch(attendanceSettingsProvider);

    return settingsAsync.when(
      loading: () => SettingsAsyncScaffold(
        title: 'Konfigurasi Absensi',
        isLoading: true,
        error: null,
        onRetry: () => ref.invalidate(attendanceSettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => SettingsAsyncScaffold(
        title: 'Konfigurasi Absensi',
        isLoading: false,
        error: error,
        onRetry: () => ref.invalidate(attendanceSettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      data: (settings) {
        final form = _draft ?? settings;
        return SettingsAsyncScaffold(
          title: 'Konfigurasi Absensi',
          isLoading: false,
          error: null,
          onRetry: () => ref.invalidate(attendanceSettingsProvider),
          canEdit: canEdit,
          isSaving: _isSaving,
          onSave: canEdit ? () => _save(form) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Jam mulai', form.workStartTime),
              _infoRow('Jam selesai', form.workEndTime),
              _infoRow('Toleransi terlambat (menit)',
                  '${form.lateToleranceMinutes}'),
              _infoRow('Shift aktif', '${form.shiftCount}'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Overtime enabled', style: SettingsTheme.tileTitleStyle),
                value: form.overtimeEnabled,
                onChanged: canEdit
                    ? (value) => setState(
                          () => _draft = AttendanceSettingsConfig(
                            id: form.id,
                            workStartTime: form.workStartTime,
                            workEndTime: form.workEndTime,
                            lateToleranceMinutes: form.lateToleranceMinutes,
                            overtimeEnabled: value,
                            gps: form.gps,
                            shiftCount: form.shiftCount,
                          ),
                        )
                    : null,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text('GPS Office', style: SettingsTheme.sectionTitleStyle),
              const SizedBox(height: AppSpacing.s8),
              if (form.gps == null)
                Text(
                  'GPS belum dikonfigurasi.',
                  style: SettingsTheme.tileDescriptionStyle,
                )
              else ...[
                _infoRow('Latitude', '${form.gps!.officeLatitude}'),
                _infoRow('Longitude', '${form.gps!.officeLongitude}'),
                _infoRow('Radius (m)', '${form.gps!.officeRadiusMeters}'),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(AttendanceSettingsConfig form) async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .updateAttendanceSettings(form.toJson());
      ref.invalidate(attendanceSettingsProvider);
      setState(() => _draft = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfigurasi absensi disimpan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan konfigurasi absensi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: SettingsTheme.tileDescriptionStyle)),
          Text(value, style: SettingsTheme.valueStyle),
        ],
      ),
    );
  }
}

class DocumentsSettingsScreen extends ConsumerStatefulWidget {
  const DocumentsSettingsScreen({super.key});

  @override
  ConsumerState<DocumentsSettingsScreen> createState() =>
      _DocumentsSettingsScreenState();
}

class _DocumentsSettingsScreenState
    extends ConsumerState<DocumentsSettingsScreen> {
  DocumentRulesConfig? _draft;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final settingsAsync = ref.watch(documentRulesProvider);

    return settingsAsync.when(
      loading: () => SettingsAsyncScaffold(
        title: 'Aturan Dokumen',
        isLoading: true,
        error: null,
        onRetry: () => ref.invalidate(documentRulesProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => SettingsAsyncScaffold(
        title: 'Aturan Dokumen',
        isLoading: false,
        error: error,
        onRetry: () => ref.invalidate(documentRulesProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      data: (rules) {
        final form = _draft ?? rules;
        return SettingsAsyncScaffold(
          title: 'Aturan Dokumen',
          isLoading: false,
          error: null,
          onRetry: () => ref.invalidate(documentRulesProvider),
          canEdit: canEdit,
          isSaving: _isSaving,
          onSave: canEdit ? () => _save(form) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                enabled: canEdit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Max file size (bytes)',
                  helperText: 'Default: 10 MB (10485760 bytes)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: TextEditingController(
                  text: '${form.maxFileSizeBytes}',
                )..selection = TextSelection.fromPosition(
                    TextPosition(offset: '${form.maxFileSizeBytes}'.length),
                  ),
                onChanged: canEdit
                    ? (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null) {
                          setState(
                            () => _draft = form.copyWith(
                              maxFileSizeBytes: parsed,
                            ),
                          );
                        }
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.s16),
              DropdownButtonFormField<String>(
                initialValue: form.compressionMode,
                decoration: InputDecoration(
                  labelText: 'Compression mode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'original', child: Text('original')),
                  DropdownMenuItem(value: 'compress', child: Text('compress')),
                ],
                onChanged: canEdit
                    ? (value) {
                        if (value != null) {
                          setState(
                            () => _draft = form.copyWith(
                              compressionMode: value,
                            ),
                          );
                        }
                      }
                    : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('OCR enabled', style: SettingsTheme.tileTitleStyle),
                value: form.ocrEnabled,
                onChanged: canEdit
                    ? (value) => setState(
                          () => _draft = form.copyWith(ocrEnabled: value),
                        )
                    : null,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text('Allowed MIME types', style: SettingsTheme.tileTitleStyle),
              ...form.allowedMimeTypes.map(
                (mime) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Text(mime, style: SettingsTheme.valueStyle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(DocumentRulesConfig form) async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .updateDocumentRules(form.toJson());
      ref.invalidate(documentRulesProvider);
      setState(() => _draft = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aturan dokumen disimpan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan aturan dokumen.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() =>
      _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  BackupSettingsConfig? _draft;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final settingsAsync = ref.watch(backupSettingsProvider);

    return settingsAsync.when(
      loading: () => SettingsAsyncScaffold(
        title: 'Konfigurasi Backup',
        isLoading: true,
        error: null,
        onRetry: () => ref.invalidate(backupSettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => SettingsAsyncScaffold(
        title: 'Konfigurasi Backup',
        isLoading: false,
        error: error,
        onRetry: () => ref.invalidate(backupSettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      data: (settings) {
        final form = _draft ?? settings;
        return SettingsAsyncScaffold(
          title: 'Konfigurasi Backup',
          isLoading: false,
          error: null,
          onRetry: () => ref.invalidate(backupSettingsProvider),
          canEdit: canEdit,
          isSaving: _isSaving,
          onSave: canEdit ? () => _save(form) : null,
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Enabled', style: SettingsTheme.tileTitleStyle),
                value: form.enabled,
                onChanged: canEdit
                    ? (value) =>
                        setState(() => _draft = form.copyWith(enabled: value))
                    : null,
              ),
              const SizedBox(height: AppSpacing.s12),
              DropdownButtonFormField<String>(
                initialValue: form.schedule,
                decoration: InputDecoration(
                  labelText: 'Schedule',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('monthly')),
                ],
                onChanged: canEdit
                    ? (value) {
                        if (value != null) {
                          setState(
                            () => _draft = form.copyWith(schedule: value),
                          );
                        }
                      }
                    : null,
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                enabled: canEdit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Retention (days)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                controller: TextEditingController(
                  text: '${form.retentionDays}',
                )..selection = TextSelection.fromPosition(
                    TextPosition(offset: '${form.retentionDays}'.length),
                  ),
                onChanged: canEdit
                    ? (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null) {
                          setState(
                            () => _draft = form.copyWith(
                              retentionDays: parsed,
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(BackupSettingsConfig form) async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(settingsRepositoryProvider)
          .updateBackupSettings(form.toJson());
      ref.invalidate(backupSettingsProvider);
      setState(() => _draft = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfigurasi backup disimpan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan konfigurasi backup.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class NotificationsConfigScreen extends ConsumerStatefulWidget {
  const NotificationsConfigScreen({super.key});

  @override
  ConsumerState<NotificationsConfigScreen> createState() =>
      _NotificationsConfigScreenState();
}

class _NotificationsConfigScreenState
    extends ConsumerState<NotificationsConfigScreen> {
  NotificationSettingsConfig? _draft;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final settingsAsync = ref.watch(notificationSettingsConfigProvider);

    return settingsAsync.when(
      loading: () => SettingsAsyncScaffold(
        title: 'Konfigurasi Notifikasi',
        isLoading: true,
        error: null,
        onRetry: () => ref.invalidate(notificationSettingsConfigProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => SettingsAsyncScaffold(
        title: 'Konfigurasi Notifikasi',
        isLoading: false,
        error: error,
        onRetry: () => ref.invalidate(notificationSettingsConfigProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      data: (config) {
        final form = _draft ?? config;
        return SettingsAsyncScaffold(
          title: 'Konfigurasi Notifikasi',
          isLoading: false,
          error: null,
          onRetry: () => ref.invalidate(notificationSettingsConfigProvider),
          canEdit: canEdit,
          isSaving: _isSaving,
          onSave: canEdit ? () => _save(form) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outlet toggles', style: SettingsTheme.sectionTitleStyle),
              _toggleSwitch(
                canEdit: canEdit,
                label: 'New order',
                value: form.settings.notifyNewOrder,
                onChanged: (value) => setState(
                  () => _draft = form.copyWith(
                    settings: form.settings.copyWith(notifyNewOrder: value),
                  ),
                ),
              ),
              _toggleSwitch(
                canEdit: canEdit,
                label: 'Payment',
                value: form.settings.notifyPayment,
                onChanged: (value) => setState(
                  () => _draft = form.copyWith(
                    settings: form.settings.copyWith(notifyPayment: value),
                  ),
                ),
              ),
              _toggleSwitch(
                canEdit: canEdit,
                label: 'Ironing finished',
                value: form.settings.notifyIroningFinished,
                onChanged: (value) => setState(
                  () => _draft = form.copyWith(
                    settings:
                        form.settings.copyWith(notifyIroningFinished: value),
                  ),
                ),
              ),
              _toggleSwitch(
                canEdit: canEdit,
                label: 'Pickup & delivery',
                value: form.settings.notifyPickupDelivery,
                onChanged: (value) => setState(
                  () => _draft = form.copyWith(
                    settings:
                        form.settings.copyWith(notifyPickupDelivery: value),
                  ),
                ),
              ),
              _toggleSwitch(
                canEdit: canEdit,
                label: 'Wallet',
                value: form.settings.notifyWallet,
                onChanged: (value) => setState(
                  () => _draft = form.copyWith(
                    settings: form.settings.copyWith(notifyWallet: value),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text('Templates (${form.templates.length})',
                  style: SettingsTheme.sectionTitleStyle),
              if (form.templates.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s8),
                  child: Text(
                    'Tidak ada template.',
                    style: SettingsTheme.tileDescriptionStyle,
                  ),
                )
              else
                ...form.templates.map(
                  (template) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: AppSpacing.s12),
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.code, style: SettingsTheme.tileTitleStyle),
                        const SizedBox(height: AppSpacing.s4),
                        Text(template.title, style: SettingsTheme.valueStyle),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          template.body,
                          style: SettingsTheme.tileDescriptionStyle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _toggleSwitch({
    required bool canEdit,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    if (canEdit) {
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: SettingsTheme.tileDescriptionStyle),
        value: value,
        onChanged: onChanged,
      );
    }
    return _toggleRow(label, value);
  }

  Future<void> _save(NotificationSettingsConfig form) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(settingsRepositoryProvider).updateNotificationSettings({
        'settings': form.settings.toJson(),
      });
      ref.invalidate(notificationSettingsConfigProvider);
      setState(() => _draft = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfigurasi notifikasi disimpan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan konfigurasi notifikasi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _toggleRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: SettingsTheme.tileDescriptionStyle)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.grey,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class DeliverySettingsScreen extends ConsumerWidget {
  const DeliverySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(isOwnerSettingsProvider);
    final settingsAsync = ref.watch(deliverySettingsProvider);

    return settingsAsync.when(
      loading: () => SettingsAsyncScaffold(
        title: 'Konfigurasi Delivery',
        isLoading: true,
        error: null,
        onRetry: () => ref.invalidate(deliverySettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      error: (error, _) => SettingsAsyncScaffold(
        title: 'Konfigurasi Delivery',
        isLoading: false,
        error: error,
        onRetry: () => ref.invalidate(deliverySettingsProvider),
        canEdit: canEdit,
        child: const SizedBox.shrink(),
      ),
      data: (settings) => SettingsAsyncScaffold(
        title: 'Konfigurasi Delivery',
        isLoading: false,
        error: null,
        onRetry: () => ref.invalidate(deliverySettingsProvider),
        canEdit: canEdit,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'Belum dikonfigurasi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (settings.message != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    settings.message!,
                    textAlign: TextAlign.center,
                    style: SettingsTheme.tileDescriptionStyle,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
