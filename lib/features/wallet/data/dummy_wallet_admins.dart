import 'package:yelo_laundry_erp/features/wallet/models/wallet_admin.dart';

const dummyWalletAdmins = <WalletAdmin>[
  WalletAdmin(id: 'admin-andi', name: 'Andi'),
  WalletAdmin(id: 'admin-budi', name: 'Budi'),
  WalletAdmin(id: 'admin-siti', name: 'Siti'),
  WalletAdmin(id: 'admin-rina', name: 'Rina'),
  WalletAdmin(id: 'admin-owner', name: 'Owner', isCurrentUser: true),
];

const dummyWalletDeductionAdmins = <WalletAdmin>[
  WalletAdmin(id: 'admin-owner', name: 'Owner', isCurrentUser: true),
  WalletAdmin(id: 'admin-kasir-andi', name: 'Kasir - Andi'),
  WalletAdmin(id: 'admin-kasir-budi', name: 'Kasir - Budi'),
  WalletAdmin(id: 'admin-kasir-siti', name: 'Kasir - Siti'),
  WalletAdmin(id: 'admin-kasir-rina', name: 'Kasir - Rina'),
];

WalletAdmin get dummyCurrentWalletAdmin {
  return dummyWalletDeductionAdmins.firstWhere((admin) => admin.isCurrentUser);
}

WalletAdmin get dummyCurrentTopUpAdmin {
  return dummyWalletAdmins.firstWhere((admin) => admin.isCurrentUser);
}
