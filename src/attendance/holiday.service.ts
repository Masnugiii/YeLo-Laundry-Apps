import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AttendanceAuditService } from './attendance-audit.service';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import { CreateHolidayDto, UpdateHolidayDto } from './dto/holiday.dto';
import { formatDateKey } from './utils/attendance-date.util';
import { HolidayRecord } from './utils/holiday-meta.util';

@Injectable()
export class HolidayService {
  constructor(
    private readonly settingsRepository: AttendanceSettingsRepository,
    private readonly auditService: AttendanceAuditService,
  ) {}

  async findAll(): Promise<ApiSuccessResponse<HolidayRecord[]>> {
    const holidays = await this.settingsRepository.listHolidays();

    return {
      success: true,
      message: 'Holidays retrieved successfully',
      data: holidays,
    };
  }

  async create(
    dto: CreateHolidayDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<HolidayRecord>> {
    const now = new Date().toISOString();
    const record: HolidayRecord = {
      id: randomUUID(),
      name: dto.name,
      date: formatDateKey(dto.date),
      description: dto.description,
      isActive: true,
      createdByEmployeeId: employeeId,
      createdAt: now,
      updatedAt: now,
    };

    await this.settingsRepository.saveHoliday(record);

    await this.auditService.log({
      employeeId,
      action: 'holiday_created',
      referenceId: record.id,
      description: `Holiday ${record.name} created`,
    });

    return {
      success: true,
      message: 'Holiday created successfully',
      data: record,
    };
  }

  async update(
    id: string,
    dto: UpdateHolidayDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<HolidayRecord>> {
    const existing = await this.settingsRepository.getHoliday(id);

    if (!existing) {
      throw new NotFoundException('Holiday not found');
    }

    const updated: HolidayRecord = {
      ...existing,
      name: dto.name ?? existing.name,
      date: dto.date ? formatDateKey(dto.date) : existing.date,
      description: dto.description ?? existing.description,
      isActive: dto.isActive ?? existing.isActive,
      updatedByEmployeeId: employeeId,
      updatedAt: new Date().toISOString(),
    };

    await this.settingsRepository.saveHoliday(updated);

    await this.auditService.log({
      employeeId,
      action: 'holiday_updated',
      referenceId: id,
      description: `Holiday ${updated.name} updated`,
    });

    return {
      success: true,
      message: 'Holiday updated successfully',
      data: updated,
    };
  }

  async remove(
    id: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    const existing = await this.settingsRepository.getHoliday(id);

    if (!existing) {
      throw new NotFoundException('Holiday not found');
    }

    await this.settingsRepository.deleteHoliday(id);

    await this.auditService.log({
      employeeId,
      action: 'holiday_deleted',
      referenceId: id,
      description: `Holiday ${existing.name} deleted`,
    });

    return {
      success: true,
      message: 'Holiday deleted successfully',
      data: { id },
    };
  }
}
