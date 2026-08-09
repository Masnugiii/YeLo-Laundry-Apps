import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AttendanceAuditService } from './attendance-audit.service';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import { CreateShiftDto, UpdateShiftDto } from './dto/shift.dto';
import { ShiftRecord } from './utils/shift-meta.util';

@Injectable()
export class ShiftService {
  constructor(
    private readonly settingsRepository: AttendanceSettingsRepository,
    private readonly auditService: AttendanceAuditService,
  ) {}

  async findAll(): Promise<ApiSuccessResponse<ShiftRecord[]>> {
    const shifts = await this.settingsRepository.listShifts();

    return {
      success: true,
      message: 'Shifts retrieved successfully',
      data: shifts,
    };
  }

  async create(
    dto: CreateShiftDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<ShiftRecord>> {
    const now = new Date().toISOString();
    const record: ShiftRecord = {
      id: randomUUID(),
      name: dto.name,
      startTime: dto.startTime,
      endTime: dto.endTime,
      toleranceMinutes: dto.toleranceMinutes ?? 0,
      breakDurationMinutes: dto.breakDurationMinutes ?? 60,
      isActive: true,
      createdByEmployeeId: employeeId,
      createdAt: now,
      updatedAt: now,
    };

    await this.settingsRepository.saveShift(record);

    await this.auditService.log({
      employeeId,
      action: 'shift_created',
      referenceId: record.id,
      description: `Shift ${record.name} created`,
    });

    return {
      success: true,
      message: 'Shift created successfully',
      data: record,
    };
  }

  async update(
    id: string,
    dto: UpdateShiftDto,
    employeeId: string,
  ): Promise<ApiSuccessResponse<ShiftRecord>> {
    const existing = await this.settingsRepository.getShift(id);

    if (!existing) {
      throw new NotFoundException('Shift not found');
    }

    const updated: ShiftRecord = {
      ...existing,
      name: dto.name ?? existing.name,
      startTime: dto.startTime ?? existing.startTime,
      endTime: dto.endTime ?? existing.endTime,
      toleranceMinutes: dto.toleranceMinutes ?? existing.toleranceMinutes,
      breakDurationMinutes:
        dto.breakDurationMinutes ?? existing.breakDurationMinutes,
      isActive: dto.isActive ?? existing.isActive,
      updatedByEmployeeId: employeeId,
      updatedAt: new Date().toISOString(),
    };

    await this.settingsRepository.saveShift(updated);

    await this.auditService.log({
      employeeId,
      action: 'shift_updated',
      referenceId: id,
      description: `Shift ${updated.name} updated`,
    });

    return {
      success: true,
      message: 'Shift updated successfully',
      data: updated,
    };
  }

  async remove(
    id: string,
    employeeId: string,
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    const existing = await this.settingsRepository.getShift(id);

    if (!existing) {
      throw new NotFoundException('Shift not found');
    }

    await this.settingsRepository.deleteShift(id);

    await this.auditService.log({
      employeeId,
      action: 'shift_deleted',
      referenceId: id,
      description: `Shift ${existing.name} deleted`,
    });

    return {
      success: true,
      message: 'Shift deleted successfully',
      data: { id },
    };
  }
}
