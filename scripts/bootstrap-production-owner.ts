/**
 * One-off bootstrap for the first production Owner account.
 *
 * - Upserts owner RBAC (permissions + owner role + role_permissions) using the
 *   same field patterns as prisma/seed.ts
 * - Creates exactly one Employee with role owner
 * - Never overwrites an existing employee (phone / employeeCode / email)
 * - Never prints the password
 * - Does not seed demo staff or master data
 *
 * Usage:
 *   DATABASE_URL="postgresql://..." npm run bootstrap:production-owner -- \
 *     --employee-code OWN001 \
 *     --full-name "Production Owner" \
 *     --phone 0812xxxxxxx \
 *     --email owner@yourcompany.com \
 *     --password '...'
 *
 * Safer password input (not in shell history):
 *   omit --password and enter it at the hidden prompt, or set OWNER_PASSWORD.
 */
import { createInterface } from 'node:readline/promises';
import { stdin as input, stdout as output, stderr } from 'node:process';
import bcrypt from 'bcrypt';
import { PrismaClient, RoleCode } from '@prisma/client';

const BCRYPT_ROUNDS = 10;
const MIN_PASSWORD_LENGTH = 6;

/** Same permission catalog as prisma/seed.ts (owner needs the full set). */
const PERMISSIONS = [
  { code: 'dashboard', name: 'Dashboard', module: 'dashboard' },
  { code: 'orders', name: 'Orders', module: 'orders' },
  { code: 'finance', name: 'Finance', module: 'finance' },
  { code: 'customers', name: 'Customers', module: 'customers' },
  { code: 'wallet', name: 'Wallet View', module: 'wallet' },
  { code: 'wallet_topup', name: 'Wallet Top Up', module: 'wallet' },
  { code: 'wallet_deduct', name: 'Wallet Deduct', module: 'wallet' },
  { code: 'loyalty', name: 'Loyalty', module: 'loyalty' },
  { code: 'attendance', name: 'Attendance', module: 'attendance' },
  { code: 'ironing', name: 'Ironing', module: 'ironing' },
  { code: 'pickup', name: 'Pickup', module: 'pickup' },
  { code: 'delivery', name: 'Delivery', module: 'delivery' },
  { code: 'reports', name: 'Reports', module: 'reports' },
  { code: 'settings', name: 'Settings', module: 'settings' },
  { code: 'notification', name: 'Notification', module: 'notification' },
  { code: 'customer_service', name: 'Customer Service', module: 'customer_service' },
  { code: 'storage', name: 'Storage', module: 'storage' },
] as const;

/** Same owner role definition as prisma/seed.ts. */
const OWNER_ROLE = {
  code: 'owner' as const satisfies RoleCode,
  name: 'Owner',
  description: 'Full system access',
};

/** Same owner permission map as prisma/seed.ts (all permission codes). */
const OWNER_PERMISSION_CODES: readonly string[] = PERMISSIONS.map((p) => p.code);

/** Reject accidental use of local seed/dev identity values. */
const FORBIDDEN_EMPLOYEE_CODES = new Set([
  'EMP0001',
  'EMP0002',
  'EMP0003',
  'EMP0004',
  'EMP0005',
]);
const FORBIDDEN_PHONES = new Set([
  '081234567890',
  '081234567891',
  '081234567892',
  '081234567893',
  '081234567894',
]);
const FORBIDDEN_PASSWORDS = new Set(['admin123']);

function normalizePhone(phone: string): string {
  let normalized = phone.replace(/[\s-]/g, '');
  if (normalized.startsWith('+62')) {
    normalized = `0${normalized.slice(3)}`;
  } else if (normalized.startsWith('62')) {
    normalized = `0${normalized.slice(2)}`;
  }
  return normalized;
}

function parseArgs(argv: string[]) {
  const args = {
    employeeCode: '' as string,
    fullName: '' as string,
    phone: '' as string,
    password: '' as string,
    email: '' as string,
    yes: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = argv[i + 1];
    switch (arg) {
      case '--employee-code':
        args.employeeCode = next ?? '';
        i += 1;
        break;
      case '--full-name':
        args.fullName = next ?? '';
        i += 1;
        break;
      case '--phone':
        args.phone = next ?? '';
        i += 1;
        break;
      case '--password':
        args.password = next ?? '';
        i += 1;
        break;
      case '--email':
        args.email = next ?? '';
        i += 1;
        break;
      case '--yes':
      case '-y':
        args.yes = true;
        break;
      case '--help':
      case '-h':
        printHelp();
        process.exit(0);
        break;
      default:
        if (arg.startsWith('-')) {
          throw new Error(`Unknown argument: ${arg}`);
        }
    }
  }

  return args;
}

function printHelp() {
  console.log(`Bootstrap the first production Owner employee.

Required env:
  DATABASE_URL

Required args:
  --employee-code <code>
  --full-name <name>
  --phone <phone>

Password (one of):
  --password <value>     CLI arg (avoid if shell history is retained)
  OWNER_PASSWORD=<value> Env (not printed)
  (interactive hidden prompt if neither is set)

Optional:
  --email <email>
  --yes                  Skip confirmation prompt

This script upserts owner RBAC only and creates one employee.
It never overwrites existing employees, never seeds demo data,
and never prints the password.
`);
}

async function promptHidden(label: string): Promise<string> {
  if (!input.isTTY) {
    throw new Error(
      'Interactive password prompt requires a TTY. Pass --password or set OWNER_PASSWORD.',
    );
  }

  return new Promise((resolve, reject) => {
    const wasRaw = input.isRaw;
    const onData = (chunk: Buffer) => {
      const text = chunk.toString('utf8');
      for (const char of text) {
        if (char === '\n' || char === '\r') {
          cleanup();
          output.write('\n');
          resolve(buffer);
          return;
        }
        if (char === '\u0003') {
          cleanup();
          reject(new Error('Cancelled'));
          return;
        }
        if (char === '\u007f' || char === '\b') {
          buffer = buffer.slice(0, -1);
          continue;
        }
        buffer += char;
      }
    };

    let buffer = '';
    const cleanup = () => {
      input.off('data', onData);
      if (input.isTTY) {
        input.setRawMode(wasRaw ?? false);
      }
      input.pause();
    };

    output.write(label);
    input.resume();
    if (input.isTTY) {
      input.setRawMode(true);
    }
    input.on('data', onData);
  });
}

async function promptConfirm(message: string): Promise<boolean> {
  const rl = createInterface({ input, output });
  try {
    const answer = await rl.question(`${message} [y/N] `);
    return /^y(es)?$/i.test(answer.trim());
  } finally {
    rl.close();
  }
}

async function resolvePassword(cliPassword: string): Promise<string> {
  const fromEnv = process.env.OWNER_PASSWORD?.trim() ?? '';
  const fromCli = cliPassword.trim();
  let password = fromCli || fromEnv;

  if (!password) {
    const first = await promptHidden('Owner password: ');
    const second = await promptHidden('Confirm password: ');
    if (first !== second) {
      throw new Error('Passwords do not match');
    }
    password = first;
  }

  if (password.length < MIN_PASSWORD_LENGTH) {
    throw new Error(
      `Password must be at least ${MIN_PASSWORD_LENGTH} characters`,
    );
  }

  if (FORBIDDEN_PASSWORDS.has(password)) {
    throw new Error(
      'Refusing seed/dev password. Choose a production password.',
    );
  }

  return password;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (!process.env.DATABASE_URL?.trim()) {
    throw new Error('DATABASE_URL is required');
  }

  const employeeCode = args.employeeCode.trim();
  const fullName = args.fullName.trim();
  const phone = normalizePhone(args.phone.trim());
  const email = args.email.trim()
    ? args.email.trim().toLowerCase()
    : null;

  if (!employeeCode || !fullName || !phone) {
    throw new Error(
      'Required: --employee-code, --full-name, and --phone (see --help)',
    );
  }

  if (FORBIDDEN_EMPLOYEE_CODES.has(employeeCode)) {
    throw new Error(
      `Refusing seed/dev employee code "${employeeCode}". Use a production code.`,
    );
  }

  if (FORBIDDEN_PHONES.has(phone)) {
    throw new Error(
      `Refusing seed/dev phone "${phone}". Use a production phone number.`,
    );
  }

  const password = await resolvePassword(args.password);

  console.log('Bootstrap production owner (preview):');
  console.log(`  employeeCode: ${employeeCode}`);
  console.log(`  fullName: ${fullName}`);
  console.log(`  phone: ${phone}`);
  console.log(`  email: ${email ?? '(none)'}`);
  console.log(`  role: owner`);
  console.log('  password: (hidden)');

  if (!args.yes) {
    const confirmed = await promptConfirm(
      'Create this owner employee and ensure owner RBAC exists?',
    );
    if (!confirmed) {
      console.log('Cancelled.');
      return;
    }
  }

  const prisma = new PrismaClient();

  try {
    await prisma.$transaction(async (tx) => {
      const existingByCode = await tx.employee.findUnique({
        where: { employeeCode },
        select: { id: true, employeeCode: true, phone: true, deletedAt: true },
      });
      if (existingByCode) {
        throw new Error(
          `Abort: employee already exists with employeeCode=${employeeCode} (id=${existingByCode.id}). Will not overwrite.`,
        );
      }

      const existingByPhone = await tx.employee.findUnique({
        where: { phone },
        select: { id: true, employeeCode: true, phone: true, deletedAt: true },
      });
      if (existingByPhone) {
        throw new Error(
          `Abort: employee already exists with phone=${phone} (id=${existingByPhone.id}, code=${existingByPhone.employeeCode}). Will not overwrite.`,
        );
      }

      if (email) {
        const existingByEmail = await tx.employee.findUnique({
          where: { email },
          select: { id: true, employeeCode: true, email: true },
        });
        if (existingByEmail) {
          throw new Error(
            `Abort: employee already exists with email=${email} (id=${existingByEmail.id}, code=${existingByEmail.employeeCode}). Will not overwrite.`,
          );
        }
      }

      // Permissions — same upsert pattern as prisma/seed.ts
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

      // Owner role only — same fields as prisma/seed.ts
      const ownerRole = await tx.role.upsert({
        where: { code: OWNER_ROLE.code },
        create: {
          code: OWNER_ROLE.code,
          name: OWNER_ROLE.name,
          description: OWNER_ROLE.description,
          isActive: true,
        },
        update: {
          name: OWNER_ROLE.name,
          description: OWNER_ROLE.description,
          isActive: true,
          deletedAt: null,
        },
      });

      for (const permissionCode of OWNER_PERMISSION_CODES) {
        const permissionId = permissionMap.get(permissionCode);
        if (!permissionId) continue;

        await tx.rolePermission.upsert({
          where: {
            roleId_permissionId: {
              roleId: ownerRole.id,
              permissionId,
            },
          },
          create: { roleId: ownerRole.id, permissionId },
          update: { deletedAt: null },
        });
      }

      const passwordHash = await bcrypt.hash(password, BCRYPT_ROUNDS);

      const employee = await tx.employee.create({
        data: {
          employeeCode,
          fullName,
          phone,
          email,
          passwordHash,
          position: 'Owner',
          status: 'active',
        },
        select: {
          id: true,
          employeeCode: true,
          fullName: true,
          phone: true,
          email: true,
          status: true,
        },
      });

      await tx.employeeRole.create({
        data: {
          employeeId: employee.id,
          roleId: ownerRole.id,
        },
      });

      console.log('Owner bootstrap complete:');
      console.log(`  id: ${employee.id}`);
      console.log(`  code: ${employee.employeeCode}`);
      console.log(`  name: ${employee.fullName}`);
      console.log(`  phone: ${employee.phone}`);
      console.log(`  email: ${employee.email ?? '-'}`);
      console.log(`  status: ${employee.status}`);
      console.log('  roles: owner');
      console.log('Login with phone + the password you provided. Password was not logged.');
    });
  } finally {
    // Avoid leaving plaintext longer than needed (best-effort).
    password.replace(/./g, '\0');
    await prisma.$disconnect();
  }
}

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  stderr.write(`Error: ${message}\n`);
  process.exit(1);
});
