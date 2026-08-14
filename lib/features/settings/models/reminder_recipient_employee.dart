import 'package:yelo_laundry_erp/core/role/role.dart';

enum ReminderRecipientRole {
  owner,
  manager,
}

extension ReminderRecipientRoleX on ReminderRecipientRole {
  String get label => switch (this) {
        ReminderRecipientRole.owner => 'Owner',
        ReminderRecipientRole.manager => managerRoleDisplayLabel,
      };
}

class ReminderRecipientEmployee {
  const ReminderRecipientEmployee({
    required this.id,
    required this.name,
    required this.role,
    required this.whatsapp,
    required this.initials,
  });

  final String id;
  final String name;
  final ReminderRecipientRole role;
  final String whatsapp;
  final String initials;
}

Set<String> defaultSelectedReminderRecipientIds() => {};
