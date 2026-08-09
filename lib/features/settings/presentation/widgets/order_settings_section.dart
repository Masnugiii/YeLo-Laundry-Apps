import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yelo_laundry_erp/features/settings/models/settings_models.dart';
import 'package:yelo_laundry_erp/features/settings/presentation/widgets/settings_section_card.dart';

class SystemSettingsSection extends StatelessWidget {
  const SystemSettingsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'SYSTEM',
      children: [
        SettingsSwitchTile(
          title: 'Auto Backup Data',
          value: settings.autoBackup,
          onChanged: (value) => onChanged(settings.copyWith(autoBackup: value)),
        ),
        SettingsSwitchTile(
          title: 'Auto Update',
          value: settings.autoUpdate,
          showDivider: false,
          onChanged: (value) => onChanged(settings.copyWith(autoUpdate: value)),
        ),
      ],
    );
  }
}

class OrderSettingsSection extends StatelessWidget {
  const OrderSettingsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'ORDER SETTINGS',
      children: [
        SettingsNavigationTile(
          title: 'Penomoran Order',
          onTap: () => context.push('/settings/order-number'),
        ),
        SettingsNavigationTile(
          title: 'Kustomisasi Struk',
          onTap: () => context.push('/settings/receipt-customization'),
        ),
        SettingsSwitchTile(
          title: 'Nomor Antrian Otomatis',
          value: settings.autoQueueNumber,
          onChanged: (value) =>
              onChanged(settings.copyWith(autoQueueNumber: value)),
        ),
        SettingsSwitchTile(
          title: 'Cetak Struk Otomatis',
          value: settings.autoPrintReceipt,
          onChanged: (value) =>
              onChanged(settings.copyWith(autoPrintReceipt: value)),
        ),
        SettingsSwitchTile(
          title: 'Kirim Struk ke WhatsApp',
          value: settings.sendReceiptToWhatsapp,
          showDivider: false,
          onChanged: (value) =>
              onChanged(settings.copyWith(sendReceiptToWhatsapp: value)),
        ),
      ],
    );
  }
}

class CustomerSettingsSection extends StatelessWidget {
  const CustomerSettingsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'CUSTOMER SETTINGS',
      children: [
        SettingsSwitchTile(
          title: 'Aktifkan Yelo Wallet',
          value: settings.yeloWalletEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(yeloWalletEnabled: value)),
        ),
        SettingsSwitchTile(
          title: 'Aktifkan Point Reward',
          value: settings.pointRewardEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(pointRewardEnabled: value)),
        ),
        SettingsSwitchTile(
          title: 'Aktifkan Membership',
          value: settings.membershipEnabled,
          showDivider: false,
          onChanged: (value) =>
              onChanged(settings.copyWith(membershipEnabled: value)),
        ),
      ],
    );
  }
}

class PickupDeliverySettingsSection extends StatelessWidget {
  const PickupDeliverySettingsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final AppSettingsState settings;
  final void Function(AppSettingsState settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      title: 'PICKUP & DELIVERY',
      children: [
        SettingsSwitchTile(
          title: 'Aktifkan Pickup',
          value: settings.pickupEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(pickupEnabled: value)),
        ),
        SettingsSwitchTile(
          title: 'Aktifkan Delivery',
          value: settings.deliveryEnabled,
          onChanged: (value) =>
              onChanged(settings.copyWith(deliveryEnabled: value)),
        ),
        SettingsSwitchTile(
          title: 'Tampilkan Google Maps',
          value: settings.showGoogleMaps,
          showDivider: false,
          onChanged: (value) =>
              onChanged(settings.copyWith(showGoogleMaps: value)),
        ),
      ],
    );
  }
}
