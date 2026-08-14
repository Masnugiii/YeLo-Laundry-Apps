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
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { OwnerWriteGuard } from '../settings/guards/owner-write.guard';
import {
  CreateRewardCatalogItemDto,
  RewardCatalogQueryDto,
  UpdateRewardCatalogItemDto,
} from './reward-catalog.dto';
import { RewardCatalogAdminService } from './reward-catalog-admin.service';

@ApiTags('Loyalty')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.LOYALTY)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('loyalty/rewards/catalog')
export class RewardCatalogController {
  constructor(
    private readonly catalogAdminService: RewardCatalogAdminService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List reward catalog items (admin)' })
  list(@Query() query: RewardCatalogQueryDto) {
    const includeInactive =
      query.includeInactive === undefined || query.includeInactive !== false;
    return this.catalogAdminService.list(includeInactive).then((data) => ({
        success: true,
        message: 'Reward catalog retrieved successfully',
        data,
      }));
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get reward catalog item detail (admin)' })
  getById(@Param('id', ParseUUIDPipe) id: string) {
    return this.catalogAdminService.getById(id).then((data) => ({
      success: true,
      message: 'Reward catalog item retrieved successfully',
      data,
    }));
  }

  @Post()
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Create reward catalog item (OWNER only)' })
  create(
    @Body() dto: CreateRewardCatalogItemDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.catalogAdminService
      .create(dto, user.employeeId)
      .then((data) => ({
        success: true,
        message: 'Reward catalog item created successfully',
        data,
      }));
  }

  @Patch(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update reward catalog item (OWNER only)' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateRewardCatalogItemDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.catalogAdminService
      .update(id, dto, user.employeeId)
      .then((data) => ({
        success: true,
        message: 'Reward catalog item updated successfully',
        data,
      }));
  }

  @Delete(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete reward catalog item (OWNER only)' })
  delete(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.catalogAdminService.delete(id, user.employeeId).then((data) => ({
      success: true,
      message: 'Reward catalog item deleted successfully',
      data,
    }));
  }
}
