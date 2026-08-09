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
import { CreateHolidayDto, UpdateHolidayDto } from './dto/holiday.dto';
import { HolidayService } from './holiday.service';
import { HolidayRecord } from './utils/holiday-meta.util';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;
const MANAGE_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Holidays')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.ATTENDANCE)
@Controller('holidays')
export class HolidayController {
  constructor(private readonly holidayService: HolidayService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List holidays' })
  @ApiResponse({
    status: 200,
    description: 'Holidays retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Holidays retrieved successfully',
        data: [
          {
            id: 'holiday-uuid',
            name: 'Independence Day',
            date: '2026-08-17',
            isActive: true,
          },
        ],
      },
    },
  })
  findAll(): Promise<ApiSuccessResponse<HolidayRecord[]>> {
    return this.holidayService.findAll();
  }

  @Post()
  @Roles(...MANAGE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create holiday' })
  @ApiBody({
    type: CreateHolidayDto,
    examples: {
      default: {
        summary: 'National holiday',
        value: {
          name: 'Independence Day',
          date: '2026-08-17',
          description: 'National holiday',
        },
      },
    },
  })
  create(
    @Body() dto: CreateHolidayDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<HolidayRecord>> {
    return this.holidayService.create(dto, user.employeeId);
  }

  @Patch(':id')
  @Roles(...MANAGE_ROLES)
  @ApiOperation({ summary: 'Update holiday' })
  @ApiParam({ name: 'id', description: 'Holiday UUID' })
  @ApiBody({ type: UpdateHolidayDto })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateHolidayDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<HolidayRecord>> {
    return this.holidayService.update(id, dto, user.employeeId);
  }

  @Delete(':id')
  @Roles(...MANAGE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete holiday' })
  @ApiParam({ name: 'id', description: 'Holiday UUID' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.holidayService.remove(id, user.employeeId);
  }
}
