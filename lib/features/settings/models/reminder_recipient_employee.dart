enum ReminderRecipientRole {
  owner,
  manager,
}

extension ReminderRecipientRoleX on ReminderRecipientRole {
  String get label => switch (this) {
        ReminderRecipientRole.owner => 'Owner',
        ReminderRecipientRole.manager => 'Manager',
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

const dummyReminderRecipientEmployees = <ReminderRecipientEmployee>[
  ReminderRecipientEmployee(
    id: 'emp-owner-001',
    name: 'Nugroho Prasetyo',
    role: ReminderRecipientRole.owner,
    whatsapp: '0812-3456-7890',
    initials: 'NP',
  ),
  ReminderRecipientEmployee(
    id: 'emp-owner-002',
    name: 'Andi Wijaya',
    role: ReminderRecipientRole.owner,
    whatsapp: '0813-4567-8901',
    initials: 'AW',
  ),
  ReminderRecipientEmployee(
    id: 'emp-owner-003',
    name: 'Budi Santoso',
    role: ReminderRecipientRole.owner,
    whatsapp: '0815-5678-9012',
    initials: 'BS',
  ),
  ReminderRecipientEmployee(
    id: 'emp-manager-001',
    name: 'Siti Rahma',
    role: ReminderRecipientRole.manager,
    whatsapp: '0817-6789-0123',
    initials: 'SR',
  ),
];

Set<String> defaultSelectedReminderRecipientIds() => {
      for (final employee in dummyReminderRecipientEmployees) employee.id,
    };
