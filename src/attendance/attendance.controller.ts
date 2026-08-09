import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { AttendanceStatus } from '@prisma/client';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  AttendanceQueryDto,
  BreakActionDto,
  CheckInDto,
  CheckOutDto,
} from './dto/attendance.dto';
import {
  AttendanceDashboard,
  AttendanceResponse,
  PaginatedAttendance,
} from './attendance.mapper';
import { AttendanceService } from './attendance.service';
import { ReportService } from './report.service';

const ALL_STAFF_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const MANAGEMENT_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

const ATTENDANCE_EXAMPLE = {
  id: 'bb0e8400-e29b-41d4-a716-446655440040',
  employeeId: '660e8400-e29b-41d4-a716-446655440001',
  attendanceDate: '2026-08-08',
  checkIn: '2026-08-08T01:00:00.000Z',
  checkOut: null,
  workingHours: 0,
  breakDurationMinutes: 0,
  overtimeMinutes: 0,
  lateMinutes: 0,
  status: AttendanceStatus.PRESENT,
  displayStatus: 'PRESENT',
};

@ApiTags('Attendance')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.ATTENDANCE)
@Controller('attendance')
export class AttendanceController {
  constructor(
    private readonly attendanceService: AttendanceService,
    private readonly reportService: ReportService,
  ) {}

  @Get('dashboard')
  @Roles(...MANAGEMENT_ROLES)
  @ApiOperation({ summary: 'Get attendance dashboard metrics' })
  @ApiResponse({
    status: 200,
    description: 'Attendance dashboard retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Attendance dashboard retrieved successfully',
        data: {
          presentToday: 18,
          lateToday: 2,
          absentToday: 3,
          onLeave: 2,
          averageWorkingHours: 7.5,
          totalOvertimeMinutes: 240,
          attendancePercentage: 92.5,
        },
      },
    },
  })
  getDashboard(): Promise<ApiSuccessResponse<AttendanceDashboard>> {
    return this.reportService.getDashboard();
  }

  @Get()
  @Roles(...ALL_STAFF_ROLES)
  @ApiOperation({ summary: 'List attendance records with search and filters' })
  @ApiResponse({
    status: 200,
    description: 'Attendance records retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Attendance records retrieved successfully',
        data: {
          items: [ATTENDANCE_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: AttendanceQueryDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<PaginatedAttendance>> {
    return this.attendanceService.findAll(query, user.employeeId, user.roles);
  }

  @Get(':id')
  @Roles(...ALL_STAFF_ROLES)
  @ApiOperation({ summary: 'Get attendance detail' })
  @ApiParam({ name: 'id', description: 'Attendance UUID' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    return this.attendanceService.findOne(id, user.employeeId, user.roles);
  }

  @Post('check-in')
  @Roles(...ALL_STAFF_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Employee check-in with GPS' })
  @ApiBody({
    type: CheckInDto,
    examples: {
      default: {
        summary: 'Check in at office',
        value: {
          latitude: -6.2088,
          longitude: 106.8456,
          accuracy: 10,
          device: 'Samsung Galaxy A54',
          notes: 'On time',
        },
      },
    },
  })
  checkIn(
    @Body() dto: CheckInDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    return this.attendanceService.checkIn(dto, user.employeeId, user.roles);
  }

  @Post('check-out')
  @Roles(...ALL_STAFF_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Employee check-out with GPS' })
  @ApiBody({
    type: CheckOutDto,
    examples: {
      default: {
        summary: 'Check out',
        value: {
          latitude: -6.2088,
          longitude: 106.8456,
          accuracy: 8,
          notes: 'Shift completed',
        },
      },
    },
  })
  checkOut(
    @Body() dto: CheckOutDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    return this.attendanceService.checkOut(dto, user.employeeId, user.roles);
  }

  @Post('break/start')
  @Roles(...ALL_STAFF_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start break during active attendance' })
  @ApiBody({ type: BreakActionDto })
  startBreak(
    @Body() dto: BreakActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    return this.attendanceService.startBreak(dto, user.employeeId, user.roles);
  }

  @Post('break/end')
  @Roles(...ALL_STAFF_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'End active break' })
  @ApiBody({ type: BreakActionDto })
  endBreak(
    @Body() dto: BreakActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<AttendanceResponse>> {
    return this.attendanceService.endBreak(dto, user.employeeId, user.roles);
  }
}
