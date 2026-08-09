import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { ROLES } from '../auth/constants/roles.constant';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AttendanceAuditService } from './attendance-audit.service';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import {
  CreateLeaveDto,
  LeaveQueryDto,
  RejectLeaveDto,
  UpdateLeaveDto,
} from './dto/leave.dto';
import { formatDateKey } from './utils/attendance-date.util';
import { LeaveRecord } from './utils/leave-meta.util';

const MANAGEMENT_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@Injectable()
export class LeaveService {
  constructor(
    private readonly settingsRepository: AttendanceSettingsRepository,
    private readonly auditService: AttendanceAuditService,
  ) {}

  async findAll(
    query: LeaveQueryDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<LeaveRecord[]>> {
    const isManagement = this.isManagement(roles);
    const leaves = await this.settingsRepository.listLeaves({
      employeeId: isManagement ? query.employeeId : requesterId,
      status: query.status,
      dateFrom: query.dateFrom ? formatDateKey(query.dateFrom) : undefined,
      dateTo: query.dateTo ? formatDateKey(query.dateTo) : undefined,
    });

    return {
      success: true,
      message: 'Leave requests retrieved successfully',
      data: leaves,
    };
  }

  async create(
    dto: CreateLeaveDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    const employeeId = this.resolveEmployeeId(dto.employeeId, requesterId, roles);

    if (dto.endDate < dto.startDate) {
      throw new BadRequestException('End date cannot be before start date');
    }

    const now = new Date().toISOString();
    const record: LeaveRecord = {
      id: randomUUID(),
      employeeId,
      leaveType: dto.leaveType,
      startDate: formatDateKey(dto.startDate),
      endDate: formatDateKey(dto.endDate),
      reason: dto.reason,
      status: 'PENDING',
      createdByEmployeeId: requesterId,
      createdAt: now,
      updatedAt: now,
    };

    await this.settingsRepository.saveLeave(record);

    await this.auditService.log({
      employeeId: requesterId,
      action: 'leave_created',
      referenceId: record.id,
      description: `Leave request ${record.leaveType} created`,
    });

    return {
      success: true,
      message: 'Leave request submitted successfully',
      data: record,
    };
  }

  async update(
    id: string,
    dto: UpdateLeaveDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    const existing = await this.settingsRepository.getLeave(id);

    if (!existing) {
      throw new NotFoundException('Leave request not found');
    }

    if (!this.isManagement(roles) && existing.employeeId !== requesterId) {
      throw new ForbiddenException('You can only update your own leave requests');
    }

    if (existing.status !== 'PENDING') {
      throw new BadRequestException('Only pending leave requests can be updated');
    }

    const updated: LeaveRecord = {
      ...existing,
      leaveType: dto.leaveType ?? existing.leaveType,
      startDate: dto.startDate
        ? formatDateKey(dto.startDate)
        : existing.startDate,
      endDate: dto.endDate ? formatDateKey(dto.endDate) : existing.endDate,
      reason: dto.reason ?? existing.reason,
      updatedByEmployeeId: requesterId,
      updatedAt: new Date().toISOString(),
    };

    await this.settingsRepository.saveLeave(updated);

    return {
      success: true,
      message: 'Leave request updated successfully',
      data: updated,
    };
  }

  async approve(
    id: string,
    approverId: string,
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    const existing = await this.settingsRepository.getLeave(id);

    if (!existing) {
      throw new NotFoundException('Leave request not found');
    }

    if (existing.status !== 'PENDING') {
      throw new BadRequestException('Leave request is not pending');
    }

    const updated: LeaveRecord = {
      ...existing,
      status: 'APPROVED',
      approvedByEmployeeId: approverId,
      updatedByEmployeeId: approverId,
      updatedAt: new Date().toISOString(),
    };

    await this.settingsRepository.saveLeave(updated);

    await this.auditService.log({
      employeeId: approverId,
      action: 'leave_approved',
      referenceId: id,
      description: `Leave ${id} approved`,
    });

    return {
      success: true,
      message: 'Leave request approved successfully',
      data: updated,
    };
  }

  async reject(
    id: string,
    dto: RejectLeaveDto,
    approverId: string,
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    const existing = await this.settingsRepository.getLeave(id);

    if (!existing) {
      throw new NotFoundException('Leave request not found');
    }

    if (existing.status !== 'PENDING') {
      throw new BadRequestException('Leave request is not pending');
    }

    const updated: LeaveRecord = {
      ...existing,
      status: 'REJECTED',
      rejectedByEmployeeId: approverId,
      rejectionReason: dto.reason,
      updatedByEmployeeId: approverId,
      updatedAt: new Date().toISOString(),
    };

    await this.settingsRepository.saveLeave(updated);

    await this.auditService.log({
      employeeId: approverId,
      action: 'leave_rejected',
      referenceId: id,
      description: `Leave ${id} rejected`,
    });

    return {
      success: true,
      message: 'Leave request rejected successfully',
      data: updated,
    };
  }

  private resolveEmployeeId(
    requestedEmployeeId: string | undefined,
    requesterId: string,
    roles: string[],
  ): string {
    if (requestedEmployeeId && requestedEmployeeId !== requesterId) {
      if (!this.isManagement(roles)) {
        throw new ForbiddenException('You can only create leave for yourself');
      }

      return requestedEmployeeId;
    }

    return requesterId;
  }

  private isManagement(roles: string[]): boolean {
    return MANAGEMENT_ROLES.some((role) => roles.includes(role));
  }
}
