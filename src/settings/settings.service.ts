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
import { AttendanceConfigService } from './config/attendance-config.service';
import { BackupSettingsService } from './config/backup-settings.service';
import { DocumentRulesService } from './config/document-rules.service';
import { NotificationConfigService } from './config/notification-config.service';
import { ConfigAuditService } from './audit/config-audit.service';
import { UpdateAttendanceSettingsDto } from './dto/update-attendance-settings.dto';
import { UpdateBackupSettingsDto } from './dto/update-backup-settings.dto';
import { UpdateCompanySettingsDto } from './dto/update-company-settings.dto';
import { UpdateDocumentRulesDto } from './dto/update-document-rules.dto';
import { UpdateNotificationSettingsDto } from './dto/update-notification-settings.dto';
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
    private readonly attendanceConfigService: AttendanceConfigService,
    private readonly documentRulesService: DocumentRulesService,
    private readonly backupSettingsService: BackupSettingsService,
    private readonly notificationConfigService: NotificationConfigService,
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
        after = await this.updateCompanySection(body);
        break;
      case 'payroll':
        after = await this.updatePayrollSection(body, employeeId);
        break;
      case 'loyalty':
        after = await this.updateLoyaltySection(body, employeeId);
        break;
      case 'attendance':
        after = await this.updateAttendanceSection(body);
        break;
      case 'documents':
        after = await this.updateDocumentsSection(body);
        break;
      case 'notifications':
        after = await this.updateNotificationsSection(body);
        break;
      case 'backup':
        after = await this.updateBackupSection(body);
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
          message:
            'No delivery configuration model exists in the current schema',
        };
      case 'attendance':
        return this.attendanceConfigService.getConfig();
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
        return this.notificationConfigService.getConfig();
      case 'backup':
        return this.backupSettingsService.getSettings();
      case 'documents':
        return this.documentRulesService.getRules();
      case 'numbering': {
        const sequences = await this.prisma.numberingSequence.findMany({
          orderBy: { type: 'asc' },
        });
        const queue = await this.prisma.queueSetting.findFirst({
          orderBy: { createdAt: 'asc' },
        });
        return {
          sequences,
          queue,
        };
      }
      default:
        return null;
    }
  }

  private async updateCompanySection(body: unknown): Promise<unknown> {
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

  private async updateAttendanceSection(body: unknown): Promise<unknown> {
    const dto = await validateSettingsDto(UpdateAttendanceSettingsDto, body);
    return this.attendanceConfigService.updateConfig(dto);
  }

  private async updateDocumentsSection(body: unknown): Promise<unknown> {
    const dto = await validateSettingsDto(UpdateDocumentRulesDto, body);
    return this.documentRulesService.updateRules(dto);
  }

  private async updateNotificationsSection(body: unknown): Promise<unknown> {
    const dto = await validateSettingsDto(UpdateNotificationSettingsDto, body);
    return this.notificationConfigService.updateConfig(dto);
  }

  private async updateBackupSection(body: unknown): Promise<unknown> {
    const dto = await validateSettingsDto(UpdateBackupSettingsDto, body);
    return this.backupSettingsService.updateSettings(dto);
  }
}
