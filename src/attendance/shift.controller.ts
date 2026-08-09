import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
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
import { CreateShiftDto, UpdateShiftDto } from './dto/shift.dto';
import { ShiftService } from './shift.service';
import { ShiftRecord } from './utils/shift-meta.util';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;
const MANAGE_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Shifts')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.ATTENDANCE)
@Controller('shifts')
export class ShiftController {
  constructor(private readonly shiftService: ShiftService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List work shifts' })
  @ApiResponse({
    status: 200,
    description: 'Shifts retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Shifts retrieved successfully',
        data: [
          {
            id: 'shift-uuid',
            name: 'Morning Shift',
            startTime: '08:00',
            endTime: '17:00',
            toleranceMinutes: 15,
            breakDurationMinutes: 60,
            isActive: true,
          },
        ],
      },
    },
  })
  findAll(): Promise<ApiSuccessResponse<ShiftRecord[]>> {
    return this.shiftService.findAll();
  }

  @Post()
  @Roles(...MANAGE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create work shift' })
  @ApiBody({
    type: CreateShiftDto,
    examples: {
      default: {
        summary: 'Morning shift',
        value: {
          name: 'Morning Shift',
          startTime: '08:00',
          endTime: '17:00',
          toleranceMinutes: 15,
          breakDurationMinutes: 60,
        },
      },
    },
  })
  create(
    @Body() dto: CreateShiftDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ShiftRecord>> {
    return this.shiftService.create(dto, user.employeeId);
  }

  @Patch(':id')
  @Roles(...MANAGE_ROLES)
  @ApiOperation({ summary: 'Update work shift' })
  @ApiParam({ name: 'id', description: 'Shift UUID' })
  @ApiBody({ type: UpdateShiftDto })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateShiftDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ShiftRecord>> {
    return this.shiftService.update(id, dto, user.employeeId);
  }

  @Delete(':id')
  @Roles(...MANAGE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete work shift' })
  @ApiParam({ name: 'id', description: 'Shift UUID' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.shiftService.remove(id, user.employeeId);
  }
}
