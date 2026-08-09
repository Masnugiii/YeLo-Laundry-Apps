import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { MasterDataAuditService } from '../master-data/audit/master-data-audit.service';
import { UpdateNumberingSequenceDto } from './numbering.dto';
import {
  formatDailyNumber,
  formatSequentialNumber,
  isNumberingType,
  NumberingSequenceConfig,
  NumberingType,
} from './numbering.types';

interface LockedSequenceRow {
  id: string;
  type: string;
  prefix: string;
  current_counter: number;
  padding: number;
  daily_reset: boolean;
  last_reset_date: Date | null;
  is_active: boolean;
}

@Injectable()
export class NumberingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: MasterDataAuditService,
  ) {}

  async listConfigurations(): Promise<NumberingSequenceConfig[]> {
    const rows = await this.prisma.numberingSequence.findMany({
      orderBy: { type: 'asc' },
    });

    return rows.map((row) => this.toConfig(row));
  }

  async getConfiguration(type: string): Promise<NumberingSequenceConfig> {
    if (!isNumberingType(type)) {
      throw new NotFoundException(`Unknown numbering type: ${type}`);
    }

    const row = await this.prisma.numberingSequence.findUnique({
      where: { type },
    });

    if (!row) {
      throw new NotFoundException(`Numbering configuration not found: ${type}`);
    }

    return this.toConfig(row);
  }

  async updateConfiguration(
    dto: UpdateNumberingSequenceDto,
    employeeId: string,
  ): Promise<NumberingSequenceConfig> {
    const before = await this.getConfiguration(dto.type);

    const row = await this.prisma.numberingSequence.update({
      where: { type: dto.type },
      data: {
        ...(dto.prefix !== undefined && { prefix: dto.prefix }),
        ...(dto.padding !== undefined && { padding: dto.padding }),
        ...(dto.dailyReset !== undefined && { dailyReset: dto.dailyReset }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
    });

    const after = this.toConfig(row);

    await this.auditService.logConfigUpdated({
      employeeId,
      module: 'numbering',
      referenceId: dto.type,
      before,
      after,
    });

    return after;
  }

  async generateNumber(
    type: NumberingType,
    tx?: Prisma.TransactionClient,
    date = new Date(),
  ): Promise<string> {
    const execute = async (client: Prisma.TransactionClient) => {
      const rows = await client.$queryRaw<LockedSequenceRow[]>`
        SELECT id, type, prefix, current_counter, padding, daily_reset, last_reset_date, is_active
        FROM numbering_sequences
        WHERE type = ${type}
        FOR UPDATE
      `;

      const config = rows[0];

      if (!config || !config.is_active) {
        throw new BadRequestException(
          `Numbering type ${type} is not configured or inactive`,
        );
      }

      const today = new Date(date);
      today.setHours(0, 0, 0, 0);

      let counter = config.current_counter;
      const lastResetDate = config.last_reset_date
        ? new Date(config.last_reset_date)
        : null;

      if (config.daily_reset) {
        if (!lastResetDate || lastResetDate.getTime() !== today.getTime()) {
          counter = 0;
        }

        counter += 1;

        await client.$executeRaw`
          UPDATE numbering_sequences
          SET current_counter = ${counter},
              last_reset_date = ${today}::date,
              updated_at = NOW()
          WHERE type = ${type}
        `;

        return formatDailyNumber(
          config.prefix,
          counter,
          config.padding,
          date,
        );
      }

      counter += 1;

      await client.numberingSequence.update({
        where: { type },
        data: { currentCounter: counter },
      });

      return formatSequentialNumber(config.prefix, counter, config.padding);
    };

    if (tx) {
      return execute(tx);
    }

    return this.prisma.$transaction((client) => execute(client));
  }

  private toConfig(row: {
    id: string;
    type: string;
    prefix: string;
    currentCounter: number;
    padding: number;
    dailyReset: boolean;
    lastResetDate: Date | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): NumberingSequenceConfig {
    return {
      id: row.id,
      type: row.type,
      prefix: row.prefix,
      currentCounter: row.currentCounter,
      padding: row.padding,
      dailyReset: row.dailyReset,
      lastResetDate: row.lastResetDate
        ? row.lastResetDate.toISOString().slice(0, 10)
        : null,
      isActive: row.isActive,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
    };
  }
}
