import { PrismaClient, RoleCode, ServiceUnitType } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const BCRYPT_ROUNDS = 10;
const DEFAULT_OWNER_PASSWORD = 'admin123';

const PERMISSIONS = [
  { code: 'dashboard', name: 'Dashboard', module: 'dashboard' },
  { code: 'orders', name: 'Orders', module: 'orders' },
  { code: 'finance', name: 'Finance', module: 'finance' },
  { code: 'customers', name: 'Customers', module: 'customers' },
  { code: 'wallet', name: 'Wallet', module: 'wallet' },
  { code: 'attendance', name: 'Attendance', module: 'attendance' },
  { code: 'ironing', name: 'Ironing', module: 'ironing' },
  { code: 'pickup', name: 'Pickup', module: 'pickup' },
  { code: 'delivery', name: 'Delivery', module: 'delivery' },
  { code: 'reports', name: 'Reports', module: 'reports' },
  { code: 'settings', name: 'Settings', module: 'settings' },
  { code: 'notification', name: 'Notification', module: 'notification' },
  { code: 'customer_service', name: 'Customer Service', module: 'customer_service' },
] as const;

const ROLES: Array<{ code: RoleCode; name: string; description: string }> = [
  { code: 'owner', name: 'Owner', description: 'Full system access' },
  { code: 'cashier', name: 'Kasir', description: 'Cashier and front desk operations' },
  { code: 'cashier_laundry', name: 'Operator', description: 'Kasir + Binatu on personal device' },
  {
    code: 'cashier_laundry_driver',
    name: 'Manajer',
    description: 'Kasir + Binatu + Driver on personal device',
  },
  { code: 'laundry', name: 'Binatu', description: 'Ironing staff' },
  { code: 'driver', name: 'Driver', description: 'Pickup and delivery driver' },
];

const ROLE_PERMISSION_MAP: Record<RoleCode, readonly string[]> = {
  owner: PERMISSIONS.map((p) => p.code),
  cashier: ['orders', 'finance', 'attendance', 'customers', 'wallet', 'pickup', 'notification', 'customer_service'],
  cashier_laundry: ['orders', 'attendance', 'ironing', 'pickup', 'notification', 'customer_service'],
  cashier_laundry_driver: [
    'dashboard',
    'orders',
    'finance',
    'reports',
    'attendance',
    'ironing',
    'pickup',
    'delivery',
    'notification',
    'customer_service',
  ],
  laundry: ['ironing', 'attendance', 'notification'],
  driver: ['pickup', 'delivery', 'attendance', 'notification'],
};

const PAYMENT_METHODS = [
  { code: 'CASH', name: 'Cash' },
  { code: 'QRIS', name: 'QRIS' },
  { code: 'BANK_TRANSFER', name: 'Bank Transfer' },
  { code: 'YELO_WALLET', name: 'Yelo Wallet' },
] as const;

const EXPENSE_CATEGORIES = [
  { code: 'ELECTRICITY', name: 'Electricity' },
  { code: 'WATER', name: 'Water' },
  { code: 'SALARY', name: 'Salary' },
  { code: 'LAUNDRY_SUPPLIES', name: 'Laundry Supplies' },
  { code: 'TRANSPORTATION', name: 'Transportation' },
  { code: 'MARKETING', name: 'Marketing' },
  { code: 'MAINTENANCE', name: 'Maintenance' },
  { code: 'OTHER', name: 'Other' },
] as const;

const SERVICE_CATEGORIES = [
  { code: 'LAUNDRY', name: 'Laundry', displayOrder: 1 },
  { code: 'IRONING', name: 'Ironing', displayOrder: 2 },
  { code: 'SHOES', name: 'Shoes', displayOrder: 3 },
  { code: 'CARPET', name: 'Carpet', displayOrder: 4 },
  { code: 'BLANKET', name: 'Blanket', displayOrder: 5 },
  { code: 'OTHERS', name: 'Others', displayOrder: 6 },
] as const;

const SERVICES: Array<{
  serviceCode: string;
  serviceName: string;
  categoryCode: (typeof SERVICE_CATEGORIES)[number]['code'];
  unitType: ServiceUnitType;
  weight: boolean;
  piece: boolean;
  durationDay: number;
}> = [
  { serviceCode: 'CKS', serviceName: 'CKS', categoryCode: 'LAUNDRY', unitType: 'kg', weight: true, piece: false, durationDay: 2 },
  { serviceCode: 'CK', serviceName: 'CK', categoryCode: 'LAUNDRY', unitType: 'kg', weight: true, piece: false, durationDay: 2 },
  { serviceCode: 'SETRIKA', serviceName: 'Setrika', categoryCode: 'IRONING', unitType: 'kg', weight: true, piece: false, durationDay: 1 },
  { serviceCode: 'KARPET', serviceName: 'Karpet', categoryCode: 'CARPET', unitType: 'item', weight: false, piece: true, durationDay: 3 },
  { serviceCode: 'BONEKA', serviceName: 'Boneka', categoryCode: 'OTHERS', unitType: 'piece', weight: false, piece: true, durationDay: 2 },
  { serviceCode: 'SEPATU', serviceName: 'Sepatu', categoryCode: 'SHOES', unitType: 'piece', weight: false, piece: true, durationDay: 2 },
  { serviceCode: 'BED_COVER', serviceName: 'Bed Cover', categoryCode: 'BLANKET', unitType: 'item', weight: false, piece: true, durationDay: 2 },
  { serviceCode: 'JAKET', serviceName: 'Jaket', categoryCode: 'LAUNDRY', unitType: 'piece', weight: false, piece: true, durationDay: 2 },
];

async function main() {
  console.log('🌱 Seeding Yelo Laundry ERP master data...\n');

  await prisma.$transaction(async (tx) => {
    const permissionMap = new Map<string, string>();
    for (const permission of PERMISSIONS) {
      const record = await tx.permission.upsert({
        where: { code: permission.code },
        create: {
          code: permission.code,
          name: permission.name,
          module: permission.module,
          description: `${permission.name} module access`,
          isActive: true,
        },
        update: {
          name: permission.name,
          module: permission.module,
          description: `${permission.name} module access`,
          isActive: true,
          deletedAt: null,
        },
      });
      permissionMap.set(permission.code, record.id);
    }

    const roleMap = new Map<RoleCode, string>();
    for (const role of ROLES) {
      const record = await tx.role.upsert({
        where: { code: role.code },
        create: {
          code: role.code,
          name: role.name,
          description: role.description,
          isActive: true,
        },
        update: {
          name: role.name,
          description: role.description,
          isActive: true,
          deletedAt: null,
        },
      });
      roleMap.set(role.code, record.id);
    }

    for (const [roleCode, permissionCodes] of Object.entries(ROLE_PERMISSION_MAP) as Array<
      [RoleCode, readonly string[]]
    >) {
      const roleId = roleMap.get(roleCode);
      if (!roleId) continue;

      for (const permissionCode of permissionCodes) {
        const permissionId = permissionMap.get(permissionCode);
        if (!permissionId) continue;

        await tx.rolePermission.upsert({
          where: {
            roleId_permissionId: { roleId, permissionId },
          },
          create: { roleId, permissionId },
          update: { deletedAt: null },
        });
      }
    }

    for (const method of PAYMENT_METHODS) {
      await tx.paymentMethod.upsert({
        where: { code: method.code },
        create: { code: method.code, name: method.name, isActive: true },
        update: { name: method.name, isActive: true, deletedAt: null },
      });
    }

    for (const category of EXPENSE_CATEGORIES) {
      await tx.expenseCategory.upsert({
        where: { code: category.code },
        create: { code: category.code, name: category.name, isActive: true },
        update: { name: category.name, isActive: true, deletedAt: null },
      });
    }

    const categoryMap = new Map<string, string>();
    for (const category of SERVICE_CATEGORIES) {
      const record = await tx.serviceCategory.upsert({
        where: { code: category.code },
        create: {
          code: category.code,
          name: category.name,
          displayOrder: category.displayOrder,
          isActive: true,
        },
        update: {
          name: category.name,
          displayOrder: category.displayOrder,
          isActive: true,
          deletedAt: null,
        },
      });
      categoryMap.set(category.code, record.id);
    }

    for (const service of SERVICES) {
      const categoryId = categoryMap.get(service.categoryCode);
      if (!categoryId) {
        throw new Error(`Service category not found: ${service.categoryCode}`);
      }

      await tx.service.upsert({
        where: { serviceCode: service.serviceCode },
        create: {
          categoryId,
          serviceCode: service.serviceCode,
          serviceName: service.serviceName,
          unitType: service.unitType,
          weight: service.weight,
          piece: service.piece,
          durationDay: service.durationDay,
          isActive: true,
        },
        update: {
          categoryId,
          serviceName: service.serviceName,
          unitType: service.unitType,
          weight: service.weight,
          piece: service.piece,
          durationDay: service.durationDay,
          isActive: true,
          deletedAt: null,
        },
      });
    }

    const existingQueue = await tx.queueSetting.findFirst();
    if (existingQueue) {
      await tx.queueSetting.update({
        where: { id: existingQueue.id },
        data: { prefix: 'YL', dailyReset: true, startingNumber: 1 },
      });
    } else {
      await tx.queueSetting.create({
        data: { prefix: 'YL', dailyReset: true, startingNumber: 1 },
      });
    }

    const existingReceipt = await tx.receiptSetting.findFirst();
    if (existingReceipt) {
      await tx.receiptSetting.update({
        where: { id: existingReceipt.id },
        data: {
          showLogo: true,
          showQRCode: true,
          footerText: 'Terima kasih telah menggunakan Yelo Laundry.',
        },
      });
    } else {
      await tx.receiptSetting.create({
        data: {
          showLogo: true,
          showQRCode: true,
          footerText: 'Terima kasih telah menggunakan Yelo Laundry.',
        },
      });
    }

    const existingCompany = await tx.companySetting.findFirst();
    if (existingCompany) {
      await tx.companySetting.update({
        where: { id: existingCompany.id },
        data: {
          companyName: 'Yelo Laundry',
          phone: null,
          email: null,
          address: null,
        },
      });
    } else {
      await tx.companySetting.create({
        data: {
          companyName: 'Yelo Laundry',
          phone: null,
          email: null,
          address: null,
        },
      });
    }

    const passwordHash = await bcrypt.hash(DEFAULT_OWNER_PASSWORD, BCRYPT_ROUNDS);

    async function upsertDevEmployee(input: {
      employeeCode: string;
      fullName: string;
      phone: string;
      position: string;
      roleCode: RoleCode;
    }) {
      const roleId = roleMap.get(input.roleCode);
      if (!roleId) {
        throw new Error(`Role ${input.roleCode} not found`);
      }

      const employee = await tx.employee.upsert({
        where: { employeeCode: input.employeeCode },
        create: {
          employeeCode: input.employeeCode,
          fullName: input.fullName,
          phone: input.phone,
          email: null,
          passwordHash,
          position: input.position,
          status: 'active',
        },
        update: {
          fullName: input.fullName,
          phone: input.phone,
          position: input.position,
          status: 'active',
          passwordHash,
          deletedAt: null,
        },
      });

      await tx.employeeRole.upsert({
        where: {
          employeeId_roleId: {
            employeeId: employee.id,
            roleId,
          },
        },
        create: {
          employeeId: employee.id,
          roleId,
        },
        update: {
          deletedAt: null,
        },
      });
    }

    await upsertDevEmployee({
      employeeCode: 'EMP0001',
      fullName: 'Owner',
      phone: '081234567890',
      position: 'Owner',
      roleCode: 'owner',
    });

    await upsertDevEmployee({
      employeeCode: 'EMP0002',
      fullName: 'Kasir Operasional',
      phone: '081234567891',
      position: 'Kasir',
      roleCode: 'cashier',
    });

    await upsertDevEmployee({
      employeeCode: 'EMP0003',
      fullName: 'Kasir Binatu',
      phone: '081234567892',
      position: 'Operator',
      roleCode: 'cashier_laundry',
    });

    await upsertDevEmployee({
      employeeCode: 'EMP0004',
      fullName: 'Manajer Driver',
      phone: '081234567893',
      position: 'Manajer',
      roleCode: 'cashier_laundry_driver',
    });

    await upsertDevEmployee({
      employeeCode: 'EMP0005',
      fullName: 'Binatu Staff',
      phone: '081234567894',
      position: 'Binatu',
      roleCode: 'laundry',
    });
  });

  console.log('✅ Master data seeded successfully');
  console.log('   • 6 roles');
  console.log('   • 12 permissions with role assignments');
  console.log('   • 4 payment methods');
  console.log('   • 8 expense categories');
  console.log('   • 6 service categories + 8 services');
  console.log('   • Queue, receipt, and company settings');
  console.log('   • Default development accounts (password: admin123)');
  console.log('     - Owner: 081234567890');
  console.log('     - Kasir Operasional: 081234567891');
  console.log('     - Kasir + Binatu: 081234567892');
  console.log('     - Manajer + Driver: 081234567893');
  console.log('     - Binatu: 081234567894');
}

main()
  .catch((error) => {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
