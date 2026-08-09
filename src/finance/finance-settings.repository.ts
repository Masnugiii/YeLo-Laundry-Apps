import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import {
  buildFinanceReferencePrefix,
  FinanceReferenceKind,
  formatFinanceReferenceNumber,
  parseFinanceReferenceSequence,
} from './utils/finance-reference.util';
import {
  ACTIVE_SHIFT_KEY,
  buildDailyClosingKey,
  buildShiftHistoryKey,
  DailyClosingRecord,
  EXPENSE_AUTO_APPROVE_KEY,
} from './utils/cash-shift-meta.util';
import {
  buildInvoiceSettingKey,
  INVOICE_SETTING_PREFIX,
  InvoiceRecord,
  parseInvoiceRecord,
} from './utils/invoice-meta.util';
import {
  buildVoucherSettingKey,
  parseVoucherRecord,
  VOUCHER_SETTING_PREFIX,
  VoucherRecord,
} from './utils/voucher-meta.util';

@Injectable()
export class FinanceSettingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async generateReferenceNumber(
    kind: FinanceReferenceKind,
    tx?: Prisma.TransactionClient,
    date = new Date(),
  ): Promise<string> {
    const client = tx ?? this.prisma;
    const prefix = buildFinanceReferencePrefix(kind, date);

    if (kind === 'PAY') {
      const latest = await client.payment.findFirst({
        where: { referenceNumber: { startsWith: prefix } },
        orderBy: { referenceNumber: 'desc' },
        select: { referenceNumber: true },
      });

      const sequence = latest?.referenceNumber
        ? parseFinanceReferenceSequence(latest.referenceNumber, prefix)
        : null;

      return formatFinanceReferenceNumber(kind, (sequence ?? 0) + 1, date);
    }

    if (kind === 'INV') {
      const latest = await client.systemSetting.findFirst({
        where: {
          settingKey: { startsWith: INVOICE_SETTING_PREFIX },
          settingValue: { contains: prefix },
        },
        orderBy: { createdAt: 'desc' },
        select: { settingValue: true },
      });

      let sequence = 0;

      if (latest?.settingValue) {
        const record = parseInvoiceRecord(latest.settingValue);

        if (record?.invoiceNumber.startsWith(prefix)) {
          sequence =
            parseFinanceReferenceSequence(record.invoiceNumber, prefix) ?? 0;
        }
      }

      return formatFinanceReferenceNumber(kind, sequence + 1, date);
    }

    if (kind === 'EXP') {
      const latest = await client.expense.findFirst({
        where: { description: { contains: prefix } },
        orderBy: { createdAt: 'desc' },
        select: { description: true },
      });

      const match = latest?.description?.match(
        new RegExp(`${prefix.replace(/-/g, '\\-')}(\\d{6})`),
      );
      const sequence = match ? Number.parseInt(match[1], 10) : 0;

      return formatFinanceReferenceNumber(kind, sequence + 1, date);
    }

    const latestRefund = await client.cashflow.findFirst({
      where: {
        description: { contains: prefix },
      },
      orderBy: { createdAt: 'desc' },
      select: { description: true },
    });

    const refundMatch = latestRefund?.description?.match(
      new RegExp(`${prefix.replace(/-/g, '\\-')}(\\d{6})`),
    );
    const refundSequence = refundMatch ? Number.parseInt(refundMatch[1], 10) : 0;

    return formatFinanceReferenceNumber(kind, refundSequence + 1, date);
  }

  async getSetting(key: string, tx?: Prisma.TransactionClient) {
    const client = tx ?? this.prisma;

    return client.systemSetting.findUnique({
      where: { settingKey: key },
      select: { id: true, settingKey: true, settingValue: true },
    });
  }

  async upsertSetting(
    key: string,
    value: string,
    description?: string,
    tx?: Prisma.TransactionClient,
  ) {
    const client = tx ?? this.prisma;

    return client.systemSetting.upsert({
      where: { settingKey: key },
      create: {
        settingKey: key,
        settingValue: value,
        description,
      },
      update: {
        settingValue: value,
        description,
      },
      select: { id: true, settingKey: true, settingValue: true },
    });
  }

  async getInvoiceByOrderId(orderId: string) {
    const setting = await this.getSetting(buildInvoiceSettingKey(orderId));

    if (!setting) {
      return null;
    }

    return parseInvoiceRecord(setting.settingValue);
  }

  async saveInvoice(record: InvoiceRecord, tx?: Prisma.TransactionClient) {
    await this.upsertSetting(
      buildInvoiceSettingKey(record.orderId),
      JSON.stringify(record),
      `Invoice ${record.invoiceNumber}`,
      tx,
    );

    return record;
  }

  async listInvoices(skip: number, take: number, search?: string) {
    const where: Prisma.SystemSettingWhereInput = {
      settingKey: { startsWith: INVOICE_SETTING_PREFIX },
    };

    if (search) {
      where.settingValue = { contains: search, mode: 'insensitive' };
    }

    const [settings, total] = await this.prisma.$transaction([
      this.prisma.systemSetting.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        select: { settingValue: true },
      }),
      this.prisma.systemSetting.count({ where }),
    ]);

    const items = settings
      .map((setting) => parseInvoiceRecord(setting.settingValue))
      .filter((record): record is InvoiceRecord => record !== null);

    return [items, total] as const;
  }

  async getVoucher(code: string) {
    const setting = await this.getSetting(buildVoucherSettingKey(code));

    if (!setting) {
      return null;
    }

    return parseVoucherRecord(setting.settingValue);
  }

  async saveVoucher(record: VoucherRecord, tx?: Prisma.TransactionClient) {
    await this.upsertSetting(
      buildVoucherSettingKey(record.code),
      JSON.stringify(record),
      `Voucher ${record.code}`,
      tx,
    );

    return record;
  }

  async incrementVoucherUsage(code: string, tx?: Prisma.TransactionClient) {
    const voucher = await this.getVoucher(code);

    if (!voucher) {
      return null;
    }

    const updated: VoucherRecord = {
      ...voucher,
      usedCount: voucher.usedCount + 1,
    };

    await this.saveVoucher(updated, tx);

    return updated;
  }

  async listVouchers() {
    const settings = await this.prisma.systemSetting.findMany({
      where: { settingKey: { startsWith: VOUCHER_SETTING_PREFIX } },
      select: { settingValue: true },
    });

    return settings
      .map((setting) => parseVoucherRecord(setting.settingValue))
      .filter((record): record is VoucherRecord => record !== null);
  }

  async getActiveShift() {
    const setting = await this.getSetting(ACTIVE_SHIFT_KEY);

    if (!setting) {
      return null;
    }

    return JSON.parse(setting.settingValue) as import('./utils/cash-shift-meta.util').CashShiftRecord;
  }

  async saveActiveShift(
    shift: import('./utils/cash-shift-meta.util').CashShiftRecord,
    tx?: Prisma.TransactionClient,
  ) {
    await this.upsertSetting(
      ACTIVE_SHIFT_KEY,
      JSON.stringify(shift),
      'Active cash register shift',
      tx,
    );

    return shift;
  }

  async clearActiveShift(tx?: Prisma.TransactionClient) {
    const client = tx ?? this.prisma;

    await client.systemSetting.deleteMany({
      where: { settingKey: ACTIVE_SHIFT_KEY },
    });
  }

  async saveShiftHistory(
    shift: import('./utils/cash-shift-meta.util').CashShiftRecord,
    tx?: Prisma.TransactionClient,
  ) {
    await this.upsertSetting(
      buildShiftHistoryKey(shift.id),
      JSON.stringify(shift),
      `Closed shift ${shift.id}`,
      tx,
    );
  }

  async saveDailyClosing(record: DailyClosingRecord, tx?: Prisma.TransactionClient) {
    await this.upsertSetting(
      buildDailyClosingKey(record.closingDate),
      JSON.stringify(record),
      `Daily closing ${record.closingDate}`,
      tx,
    );

    return record;
  }

  async getDailyClosing(date: string) {
    const setting = await this.getSetting(buildDailyClosingKey(date));

    if (!setting) {
      return null;
    }

    return JSON.parse(setting.settingValue) as DailyClosingRecord;
  }

  async getExpenseAutoApproveLimit(): Promise<number> {
    const setting = await this.getSetting(EXPENSE_AUTO_APPROVE_KEY);

    if (!setting) {
      return 500_000;
    }

    const parsed = Number.parseFloat(setting.settingValue);

    return Number.isNaN(parsed) ? 500_000 : parsed;
  }
}
