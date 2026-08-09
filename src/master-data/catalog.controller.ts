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
import {
  CreateServiceDto,
  CreateServicePriceDto,
  ServiceQueryDto,
  UpdateServiceDto,
  UpdateServicePriceDto,
} from './catalog.dto';
import { CatalogService } from './catalog.service';

@ApiTags('Catalog')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.SETTINGS)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('services')
  @ApiOperation({ summary: 'List laundry services' })
  async listServices(@Query() query: ServiceQueryDto) {
    const data = await this.catalogService.listServices(query);
    return {
      success: true,
      message: 'Services retrieved successfully',
      data,
    };
  }

  @Get('services/:id')
  @ApiOperation({ summary: 'Get service detail' })
  async getService(@Param('id', ParseUUIDPipe) id: string) {
    const data = await this.catalogService.getService(id);
    return {
      success: true,
      message: 'Service retrieved successfully',
      data,
    };
  }

  @Post('services')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Create service (OWNER only)' })
  async createService(
    @Body() dto: CreateServiceDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.catalogService.createService(dto, user.employeeId);
    return {
      success: true,
      message: 'Service created successfully',
      data,
    };
  }

  @Patch('services/:id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update service (OWNER only)' })
  async updateService(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateServiceDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.catalogService.updateService(
      id,
      dto,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Service updated successfully',
      data,
    };
  }

  @Delete('services/:id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete service (OWNER only)' })
  async deleteService(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.catalogService.deleteService(id, user.employeeId);
    return {
      success: true,
      message: 'Service deleted successfully',
      data,
    };
  }

  @Get('prices')
  @ApiOperation({ summary: 'List service prices' })
  async listPrices(@Query('serviceId') serviceId?: string) {
    const data = await this.catalogService.listPrices(serviceId);
    return {
      success: true,
      message: 'Service prices retrieved successfully',
      data,
    };
  }

  @Post('prices')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Create service price (OWNER only)' })
  async createPrice(
    @Body() dto: CreateServicePriceDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.catalogService.createPrice(dto, user.employeeId);
    return {
      success: true,
      message: 'Service price created successfully',
      data,
    };
  }

  @Patch('prices/:id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update service price (OWNER only)' })
  async updatePrice(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateServicePriceDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.catalogService.updatePrice(
      id,
      dto,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Service price updated successfully',
      data,
    };
  }

  @Delete('prices/:id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete service price (OWNER only)' })
  async deletePrice(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.catalogService.deletePrice(id, user.employeeId);
    return {
      success: true,
      message: 'Service price deleted successfully',
      data,
    };
  }
}
