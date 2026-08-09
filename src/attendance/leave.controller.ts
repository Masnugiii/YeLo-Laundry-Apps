import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
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
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CreateLeaveDto,
  LeaveQueryDto,
  RejectLeaveDto,
  UpdateLeaveDto,
} from './dto/leave.dto';
import { LeaveService } from './leave.service';
import { LeaveRecord } from './utils/leave-meta.util';

const ALL_STAFF_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;
const APPROVE_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Leaves')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.ATTENDANCE)
@Controller('leaves')
export class LeaveController {
  constructor(private readonly leaveService: LeaveService) {}

  @Get()
  @Roles(...ALL_STAFF_ROLES)
  @ApiOperation({ summary: 'List leave requests' })
  @ApiResponse({
    status: 200,
    description: 'Leave requests retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Leave requests retrieved successfully',
        data: [
          {
            id: 'leave-uuid',
            employeeId: '660e8400-e29b-41d4-a716-446655440001',
            leaveType: 'ANNUAL',
            startDate: '2026-08-10',
            endDate: '2026-08-12',
            status: 'PENDING',
            reason: 'Family vacation',
          },
        ],
      },
    },
  })
  findAll(
    @Query() query: LeaveQueryDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LeaveRecord[]>> {
    return this.leaveService.findAll(query, user.employeeId, user.roles);
  }

  @Post()
  @Roles(...ALL_STAFF_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit leave request' })
  @ApiBody({
    type: CreateLeaveDto,
    examples: {
      default: {
        summary: 'Annual leave',
        value: {
          leaveType: 'ANNUAL',
          startDate: '2026-08-10',
          endDate: '2026-08-12',
          reason: 'Family vacation',
        },
      },
    },
  })
  create(
    @Body() dto: CreateLeaveDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    return this.leaveService.create(dto, user.employeeId, user.roles);
  }

  @Patch(':id')
  @Roles(...ALL_STAFF_ROLES)
  @ApiOperation({ summary: 'Update pending leave request' })
  @ApiParam({ name: 'id', description: 'Leave UUID' })
  @ApiBody({ type: UpdateLeaveDto })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateLeaveDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    return this.leaveService.update(id, dto, user.employeeId, user.roles);
  }

  @Post(':id/approve')
  @Roles(...APPROVE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve leave request' })
  @ApiParam({ name: 'id', description: 'Leave UUID' })
  approve(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    return this.leaveService.approve(id, user.employeeId);
  }

  @Post(':id/reject')
  @Roles(...APPROVE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Reject leave request' })
  @ApiParam({ name: 'id', description: 'Leave UUID' })
  @ApiBody({ type: RejectLeaveDto })
  reject(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RejectLeaveDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LeaveRecord>> {
    return this.leaveService.reject(id, dto, user.employeeId);
  }
}
