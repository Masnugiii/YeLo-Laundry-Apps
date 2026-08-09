import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ROLES } from '../auth/constants/roles.constant';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AttendanceAuditService } from './attendance-audit.service';
import { AttendanceSettingsRepository } from './attendance-settings.repository';
import {
  AttendanceResponse,
  PaginatedAttendance,
  toAttendanceResponse,
} from './attendance.mapper';
import { AttendanceRepository } from './attendance.repository';
import {
  AttendanceQueryDto,
  BreakActionDto,
  CheckInDto,
  CheckOutDto,
} from './dto/attendance.dto';

const MANAGEMENT_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@Injectable()
export class AttendanceService {
  constructor(
    private readonly attendanceRepository: AttendanceRepository,
    private readonly settingsRepository: AttendanceSettingsRepository,
    private readonly auditService: AttendanceAuditService,
  ) {}

  async findAll(
    query: AttendanceQueryDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<PaginatedAttendance>> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const scopedEmployeeId = this.isManagement(roles)
      ? query.employeeId
      : requesterId;

    if (!this.isManagement(roles) && query.employeeId && query.employeeId !== requesterId) {
      throw new ForbiddenException('You can only view your own attendance');
    }

    const [records, total] = await this.attendanceRepository.findMany(
      query,
      scopedEmployeeId,
    );

    const items = await Promise.all(
      records.map((record) => this.mapWithContext(record)),
    );

    return {
      success: true,
      message: 'Attendance records retrieved successfully',
      data: {
        items,
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
        },
      },
    };
  }

  async findOne(
    id: string,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    const record = await this.attendanceRepository.findById(id);

    if (!record) {
      throw new NotFoundException('Attendance record not found');
    }

    if (!this.isManagement(roles) && record.employeeId !== requesterId) {
      throw new ForbiddenException('You can only view your own attendance');
    }

    return {
      success: true,
      message: 'Attendance record retrieved successfully',
      data: await this.mapWithContext(record),
    };
  }

  async checkIn(
    dto: CheckInDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    const employeeId = this.resolveEmployeeId(dto.employeeId, requesterId, roles);

    await this.attendanceRepository.validateGps(dto.latitude, dto.longitude);

    let record;

    try {
      record = await this.attendanceRepository.checkIn({
        employeeId,
        latitude: dto.latitude,
        longitude: dto.longitude,
        accuracy: dto.accuracy,
        photoUrl: dto.photoUrl,
        device: dto.device,
        notes: dto.notes,
        shiftId: dto.shiftId,
      });
    } catch (error) {
      this.handleAttendanceError(error);
    }

    await this.auditService.log({
      employeeId: requesterId,
      action: 'check_in',
      referenceId: record!.id,
      description: `Employee ${employeeId} checked in`,
    });

    return {
      success: true,
      message: 'Check-in successful',
      data: await this.mapWithContext(record!),
    };
  }

  async checkOut(
    dto: CheckOutDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    const employeeId = this.resolveEmployeeId(dto.employeeId, requesterId, roles);

    await this.attendanceRepository.validateGps(dto.latitude, dto.longitude);

    let record;

    try {
      record = await this.attendanceRepository.checkOut({
        employeeId,
        latitude: dto.latitude,
        longitude: dto.longitude,
        accuracy: dto.accuracy,
        photoUrl: dto.photoUrl,
        notes: dto.notes,
      });
    } catch (error) {
      this.handleAttendanceError(error);
    }

    await this.auditService.log({
      employeeId: requesterId,
      action: 'check_out',
      referenceId: record!.id,
      description: `Employee ${employeeId} checked out`,
    });

    return {
      success: true,
      message: 'Check-out successful',
      data: await this.mapWithContext(record!),
    };
  }

  async startBreak(
    dto: BreakActionDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    const employeeId = this.resolveEmployeeId(dto.employeeId, requesterId, roles);

    let record;

    try {
      record = await this.attendanceRepository.startBreak(employeeId, dto.notes);
    } catch (error) {
      this.handleAttendanceError(error);
    }

    return {
      success: true,
      message: 'Break started successfully',
      data: await this.mapWithContext(record!),
    };
  }

  async endBreak(
    dto: BreakActionDto,
    requesterId: string,
    roles: string[],
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    const employeeId = this.resolveEmployeeId(dto.employeeId, requesterId, roles);

    let record;

    try {
      record = await this.attendanceRepository.endBreak(employeeId, dto.notes);
    } catch (error) {
      this.handleAttendanceError(error);
    }

    return {
      success: true,
      message: 'Break ended successfully',
      data: await this.mapWithContext(record!),
    };
  }

  private resolveEmployeeId(
    requestedEmployeeId: string | undefined,
    requesterId: string,
    roles: string[],
  ): string {
    if (requestedEmployeeId && requestedEmployeeId !== requesterId) {
      if (!this.isManagement(roles)) {
        throw new ForbiddenException('You can only manage your own attendance');
      }

      return requestedEmployeeId;
    }

    return requesterId;
  }

  private isManagement(roles: string[]): boolean {
    return MANAGEMENT_ROLES.some((role) => roles.includes(role));
  }

  private async mapWithContext(
    record: Parameters<typeof toAttendanceResponse>[0],
  ): Promise<AttendanceResponse> {
    const [holiday, leave] = await Promise.all([
      this.settingsRepository.getHolidayForDate(record.attendanceDate),
      this.settingsRepository.getApprovedLeaveForDate(
        record.employeeId,
        record.attendanceDate,
      ),
    ]);

    return toAttendanceResponse(record, {
      isHoliday: Boolean(holiday),
      isOnLeave: Boolean(leave),
    });
  }

  private handleAttendanceError(error: unknown): never {
    if (error instanceof Error) {
      switch (error.message) {
        case 'ALREADY_CHECKED_IN':
          throw new BadRequestException('Employee has already checked in today');
        case 'ALREADY_COMPLETED':
          throw new BadRequestException('Attendance for today is already completed');
        case 'NOT_CHECKED_IN':
          throw new BadRequestException('Employee has not checked in yet');
        case 'ALREADY_CHECKED_OUT':
          throw new BadRequestException('Employee has already checked out');
        case 'BREAK_ACTIVE':
          throw new BadRequestException('A break is already active');
        case 'NO_ACTIVE_BREAK':
          throw new BadRequestException('No active break to end');
        case 'OUT_OF_RADIUS':
          throw new BadRequestException('Check-in location is outside office radius');
        case 'HOLIDAY':
          throw new BadRequestException('Today is a holiday');
        case 'ON_LEAVE':
          throw new BadRequestException('Employee is on approved leave today');
      }
    }

    throw error;
  }
}
