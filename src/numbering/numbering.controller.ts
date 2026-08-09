import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { OwnerWriteGuard } from '../settings/guards/owner-write.guard';
import { NumberingTypeParamDto, UpdateNumberingSequenceDto } from './numbering.dto';
import { NumberingService } from './numbering.service';

@ApiTags('Numbering')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.SETTINGS)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('numbering')
export class NumberingController {
  constructor(private readonly numberingService: NumberingService) {}

  @Get()
  @ApiOperation({ summary: 'List business numbering configurations' })
  async list() {
    const data = await this.numberingService.listConfigurations();
    return {
      success: true,
      message: 'Numbering configurations retrieved successfully',
      data,
    };
  }

  @Get(':type')
  @ApiOperation({ summary: 'Get numbering configuration by type' })
  async getOne(@Param() params: NumberingTypeParamDto) {
    const data = await this.numberingService.getConfiguration(params.type);
    return {
      success: true,
      message: 'Numbering configuration retrieved successfully',
      data,
    };
  }

  @Patch(':type')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update numbering configuration (OWNER only)' })
  async update(
    @Param() params: NumberingTypeParamDto,
    @Body() body: Omit<UpdateNumberingSequenceDto, 'type'>,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.numberingService.updateConfiguration(
      { type: params.type, ...body },
      user.employeeId,
    );

    return {
      success: true,
      message: 'Numbering configuration updated successfully',
      data,
    };
  }
}
