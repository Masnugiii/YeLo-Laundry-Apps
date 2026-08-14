import type {
  EmployeeRole,
  InternalAccessFeature,
} from "@/types/internal-access";

export const INTERNAL_ACCESS_FEATURES: InternalAccessFeature[] = [
  {
    id: "dashboard",
    label: "Dashboard",
    description: "Ringkasan operasional dan metrik utama.",
    viewPermissions: ["dashboard"],
  },
  {
    id: "customer",
    label: "Customer",
    description: "Daftar pelanggan dan profil customer.",
    viewPermissions: ["customers"],
  },
  {
    id: "order",
    label: "Order",
    description: "Daftar order dan detail transaksi.",
    viewPermissions: ["orders"],
    linkedFeatureIds: ["order-new"],
  },
  {
    id: "order-new",
    label: "Order Baru",
    description: "Membuat order baru dari aplikasi internal.",
    viewPermissions: ["orders"],
    linkedFeatureIds: ["order"],
  },
  {
    id: "unpaid-orders",
    label: "Belum Bayar",
    description: "Order yang menunggu pembayaran.",
    viewPermissions: ["orders", "finance"],
    viewMatch: "any",
    managePermissions: ["finance"],
  },
  {
    id: "pickup",
    label: "Pickup",
    description: "Permintaan dan status pickup.",
    viewPermissions: ["pickup"],
  },
  {
    id: "delivery",
    label: "Delivery",
    description: "Permintaan dan status delivery.",
    viewPermissions: ["delivery"],
  },
  {
    id: "storage",
    label: "Laci Laundry",
    description: "Penyimpanan laundry di laci/kotak.",
    viewPermissions: ["storage"],
    manageMode: "role-default",
    manageRoleDefaults: {
      OWNER: false,
      MANAGER: true,
      CASHIER: false,
      OPERATOR: true,
      BINATU: true,
      DRIVER: false,
    },
  },
  {
    id: "wallet",
    label: "Wallet",
    description: "Saldo dan transaksi Yelo Wallet.",
    capabilityLayout: "wallet",
    viewPermissions: ["wallet"],
    topUpPermissions: ["wallet_topup"],
    deductPermissions: ["wallet_deduct"],
    viewHint: "Melihat saldo dan riwayat transaksi.",
    topUpHint: "Tambah Saldo pelanggan.",
    deductHint: "Kurangi Saldo pelanggan.",
  },
  {
    id: "notification",
    label: "Notifikasi",
    description: "Pusat notifikasi internal.",
    viewPermissions: ["notification"],
  },
];

const MATRIX_PERMISSION_CODES = new Set(
  INTERNAL_ACCESS_FEATURES.flatMap((feature) => [
    ...feature.viewPermissions,
    ...(feature.managePermissions ?? feature.viewPermissions),
    ...(feature.topUpPermissions ?? []),
    ...(feature.deductPermissions ?? []),
  ]),
);

export function getMatrixPermissionCodes(): Set<string> {
  return MATRIX_PERMISSION_CODES;
}

export function getManagePermissionCodes(feature: InternalAccessFeature): string[] {
  return feature.managePermissions ?? feature.viewPermissions;
}

export function isRoleDefaultManageFeature(feature: InternalAccessFeature): boolean {
  return feature.manageMode === "role-default";
}

export function getRoleDefaultManage(
  feature: InternalAccessFeature,
  role: EmployeeRole,
): boolean {
  return feature.manageRoleDefaults?.[role] ?? false;
}

export function deriveMatrixFromPermissions(
  assignedCodes: Set<string>,
  role: EmployeeRole,
): Record<string, { view: boolean; manage: boolean; topUp?: boolean; deduct?: boolean }> {
  const state: Record<string, { view: boolean; manage: boolean; topUp?: boolean; deduct?: boolean }> = {};

  for (const feature of INTERNAL_ACCESS_FEATURES) {
    if (feature.capabilityLayout === "wallet") {
      state[feature.id] = {
        view: assignedCodes.has("wallet"),
        manage: false,
        topUp: assignedCodes.has("wallet_topup"),
        deduct: assignedCodes.has("wallet_deduct"),
      };
      continue;
    }

    const view =
      feature.id === "unpaid-orders"
        ? assignedCodes.has("orders") || assignedCodes.has("finance")
        : feature.viewMatch === "any"
          ? feature.viewPermissions.some((code) => assignedCodes.has(code))
          : feature.viewPermissions.every((code) => assignedCodes.has(code));

    const manage = isRoleDefaultManageFeature(feature)
      ? getRoleDefaultManage(feature, role)
      : feature.id === "unpaid-orders"
        ? assignedCodes.has("finance")
        : getManagePermissionCodes(feature).every((code) =>
            assignedCodes.has(code),
          );

    state[feature.id] = { view, manage };
  }

  return state;
}

export function derivePermissionCodesFromMatrix(
  matrix: Record<string, { view: boolean; manage: boolean; topUp?: boolean; deduct?: boolean }>,
): Set<string> {
  const codes = new Set<string>();

  for (const feature of INTERNAL_ACCESS_FEATURES) {
    const entry = matrix[feature.id];
    if (!entry) continue;

    if (feature.capabilityLayout === "wallet") {
      if (entry.view) {
        codes.add("wallet");
      }
      if (entry.topUp) {
        codes.add("wallet_topup");
      }
      if (entry.deduct) {
        codes.add("wallet_deduct");
      }
      continue;
    }

    if (feature.id === "unpaid-orders") {
      if (entry.manage) {
        codes.add("orders");
        codes.add("finance");
      } else if (entry.view) {
        codes.add("orders");
      }
      continue;
    }

    if (isRoleDefaultManageFeature(feature)) {
      if (entry.view) {
        for (const code of feature.viewPermissions) {
          codes.add(code);
        }
      }
      continue;
    }

    const manageCodes = getManagePermissionCodes(feature);
    const linked =
      manageCodes.length === feature.viewPermissions.length &&
      manageCodes.every((code, index) => code === feature.viewPermissions[index]);

    if (linked) {
      if (entry.view || entry.manage) {
        for (const code of feature.viewPermissions) {
          codes.add(code);
        }
      }
      continue;
    }

    if (entry.view) {
      for (const code of feature.viewPermissions) {
        codes.add(code);
      }
    }

    if (entry.manage) {
      for (const code of manageCodes) {
        codes.add(code);
      }
    }
  }

  return codes;
}

export function syncLinkedFeatures(
  matrix: Record<string, { view: boolean; manage: boolean; topUp?: boolean; deduct?: boolean }>,
  featureId: string,
  patch: Partial<{ view: boolean; manage: boolean; topUp: boolean; deduct: boolean }>,
): Record<string, { view: boolean; manage: boolean; topUp?: boolean; deduct?: boolean }> {
  const feature = INTERNAL_ACCESS_FEATURES.find((item) => item.id === featureId);
  if (!feature) return matrix;

  const current = matrix[featureId] ?? { view: false, manage: false };
  let nextPatch = { ...patch };

  if (feature.capabilityLayout === "wallet") {
    if (nextPatch.view === false) {
      nextPatch = { ...nextPatch, topUp: false, deduct: false };
    }
    if (nextPatch.topUp === true || nextPatch.deduct === true) {
      nextPatch.view = true;
    }
  }

  const next = {
    ...matrix,
    [featureId]: {
      ...current,
      ...nextPatch,
    },
  };

  if (feature.linkedFeatureIds?.length) {
    for (const linkedId of feature.linkedFeatureIds) {
      next[linkedId] = {
        ...next[linkedId],
        ...patch,
      };
    }
  }

  return next;
}
