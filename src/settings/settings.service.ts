import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { AdminSettingsService } from '../admin/admin-settings.service';
import { LoyaltySettingsService } from '../loyalty/loyalty-settings.service';
import { UpdateLoyaltySettingsDto } from '../loyalty/loyalty.dto';
import { LoyaltySettings } from '../loyalty/loyalty.types';
import { PayrollService } from '../payroll/payroll.service';
import { UpdatePayrollSettingsDto } from '../payroll/payroll.dto';
import { PayrollSettings } from '../payroll/payroll.types';
import { PrismaService } from '../database/prisma/prisma.service';
import { ConfigAuditService } from './audit/config-audit.service';
import { UpdateCompanySettingsDto } from './dto/update-company-settings.dto';
import {
  isSettingsSection,
  isWritableSettingsSection,
  SETTINGS_SECTION_META,
  SettingsManifestResponse,
  SettingsSection,
  SettingsSectionUpdateResponse,
  WRITABLE_SETTINGS_SECTIONS,
} from './settings.types';
import { validateSettingsDto } from './utils/validate-settings-dto.util';

@Injectable()
export class SettingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly adminSettingsService: AdminSettingsService,
    private readonly payrollService: PayrollService,
    private readonly loyaltySettingsService: LoyaltySettingsService,
    private readonly configAuditService: ConfigAuditService,
  ) {}

  async getManifest(): Promise<SettingsManifestResponse> {
    const sections = {} as Partial<Record<SettingsSection, unknown>>;

    for (const section of Object.keys(SETTINGS_SECTION_META) as SettingsSection[]) {
      sections[section] = await this.readSection(section);
    }

    return {
      writableSections: [...WRITABLE_SETTINGS_SECTIONS],
      sections,
    };
  }

  async getSection(section: string): Promise<unknown> {
    if (!isSettingsSection(section)) {
      throw new NotFoundException(`Unknown settings section: ${section}`);
    }

    return this.readSection(section);
  }

  async updateSection(
    section: string,
    body: unknown,
    employeeId: string,
  ): Promise<SettingsSectionUpdateResponse> {
    if (!isSettingsSection(section)) {
      throw new NotFoundException(`Unknown settings section: ${section}`);
    }

    if (!isWritableSettingsSection(section)) {
      throw new BadRequestException(
        `Settings section "${section}" is read-only in the current release`,
      );
    }

    const before = await this.readSection(section);
    let after: unknown;

    switch (section) {
      case 'company':
        after = await this.updateCompanySection(body, employeeId);
        break;
      case 'payroll':
        after = await this.updatePayrollSection(body, employeeId);
        break;
      case 'loyalty':
        after = await this.updateLoyaltySection(body, employeeId);
        break;
      default:
        throw new BadRequestException(
          `Settings section "${section}" is not writable`,
        );
    }

    await this.configAuditService.logConfigUpdated({
      employeeId,
      section,
      before,
      after,
    });

    return { section, data: after };
  }

  private async readSection(section: SettingsSection): Promise<unknown> {
    switch (section) {
      case 'company':
        return this.adminSettingsService.getCompanySettings();
      case 'services':
        return this.prisma.service.findMany({
          where: { deletedAt: null, isActive: true },
          include: { category: { select: { code: true, name: true } } },
          orderBy: { serviceName: 'asc' },
        });
      case 'pricing':
        return this.prisma.servicePrice.findMany({
          where: { deletedAt: null, isActive: true },
          include: {
            service: {
              select: { serviceCode: true, serviceName: true, isActive: true },
            },
          },
          orderBy: [{ serviceId: 'asc' }, { effectiveDate: 'desc' }],
        });
      case 'payroll':
        return this.payrollService.getSettings();
      case 'loyalty':
        return this.loyaltySettingsService.getSettings();
      case 'membership': {
        const loyalty = await this.loyaltySettingsService.getSettings();
        return { membershipLevels: loyalty.membershipLevels };
      }
      case 'wallet': {
        const loyalty = await this.loyaltySettingsService.getSettings();
        return { wallet: loyalty.wallet };
      }
      case 'delivery':
        return {
          status: 'not_configured',
          message: 'Delivery configuration will be available in a future release',
        };
      case 'attendance':
        return this.readAttendanceSettings();
      case 'payment_methods':
        return this.prisma.paymentMethod.findMany({
          where: { deletedAt: null },
          orderBy: { name: 'asc' },
        });
      case 'expense_categories':
        return this.prisma.expenseCategory.findMany({
          where: { deletedAt: null },
          orderBy: { name: 'asc' },
        });
      case 'notifications':
        return this.prisma.notificationTemplate.findMany({
          where: { deletedAt: null },
          orderBy: { code: 'asc' },
        });
      case 'backup':
        return {
          status: 'not_configured',
          message: 'Backup configuration will be available in a future release',
        };
      case 'documents':
        return {
          status: 'not_configured',
          message: 'Document rules will be available in a future release',
        };
      case 'numbering': {
        const queue = await this.prisma.queueSetting.findFirst({
          orderBy: { createdAt: 'asc' },
        });
        return {
          queue,
          message: 'Unified business numbering will be available in a future release',
        };
      }
      default:
        return null;
    }
  }

  private async readAttendanceSettings() {
    const [attendanceSetting, shifts] = await Promise.all([
      this.prisma.attendanceSetting.findFirst({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.systemSetting.findMany({
        where: { settingKey: { startsWith: 'attendance.shift.' } },
        select: { settingKey: true, settingValue: true },
      }),
    ]);

    return {
      attendanceSetting,
      shiftCount: shifts.length,
    };
  }

  private async updateCompanySection(
    body: unknown,
    _employeeId: string,
  ): Promise<unknown> {
    const dto = await validateSettingsDto(UpdateCompanySettingsDto, body);
    return this.adminSettingsService.updateCompanySettings(dto);
  }

  private async updatePayrollSection(
    body: unknown,
    employeeId: string,
  ): Promise<PayrollSettings> {
    const dto = await validateSettingsDto(UpdatePayrollSettingsDto, body);
    return this.payrollService.updateSettings(
      dto as Partial<PayrollSettings>,
      employeeId,
      {
        skipAudit: true,
      },
    );
  }

  private async updateLoyaltySection(
    body: unknown,
    employeeId: string,
  ): Promise<LoyaltySettings> {
    const dto = await validateSettingsDto(UpdateLoyaltySettingsDto, body);
    return this.loyaltySettingsService.updateSettings(
      dto as Partial<LoyaltySettings>,
      employeeId,
      {
        skipAudit: true,
      },
    );
  }
}
