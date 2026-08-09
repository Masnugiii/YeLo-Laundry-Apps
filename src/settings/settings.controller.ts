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
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { SettingsSectionParamDto } from './dto/settings-section-param.dto';
import { OwnerWriteGuard } from './guards/owner-write.guard';
import { SettingsService } from './settings.service';
import {
  SettingsManifestResponse,
  SettingsSectionUpdateResponse,
} from './settings.types';

const CONFIG_READ_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Settings')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.SETTINGS)
@Roles(...CONFIG_READ_ROLES)
@Controller('settings')
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get()
  @ApiOperation({ summary: 'Get unified system configuration manifest' })
  async getSettings(): Promise<{
    success: true;
    message: string;
    data: SettingsManifestResponse;
  }> {
    const data = await this.settingsService.getManifest();
    return {
      success: true,
      message: 'Settings retrieved successfully',
      data,
    };
  }

  @Get(':section')
  @ApiOperation({ summary: 'Get a single configuration section' })
  @ApiParam({ name: 'section', description: 'Configuration section key' })
  async getSection(@Param() params: SettingsSectionParamDto) {
    const data = await this.settingsService.getSection(params.section);
    return {
      success: true,
      message: 'Settings section retrieved successfully',
      data,
    };
  }

  @Patch(':section')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update a configuration section (OWNER only)' })
  @ApiParam({ name: 'section', description: 'Configuration section key' })
  async updateSection(
    @Param() params: SettingsSectionParamDto,
    @Body() body: unknown,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<{
    success: true;
    message: string;
    data: SettingsSectionUpdateResponse;
  }> {
    const data = await this.settingsService.updateSection(
      params.section,
      body,
      user.employeeId,
    );

    return {
      success: true,
      message: 'Settings section updated successfully',
      data,
    };
  }
}
