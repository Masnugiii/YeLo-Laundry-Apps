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
import { AssignStorageDto, MoveStorageDto, StorageSearchQueryDto } from './dto/storage.dto';
import { StorageService } from './storage.service';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const WRITE_ROLES = [ROLES.MANAGER, ROLES.OPERATOR, ROLES.BINATU] as const;

@ApiTags('Storage')
@ApiBearerAuth()
@Permissions(PERMISSIONS.STORAGE)
@Controller('storage')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Get('dashboard')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Storage overview dashboard' })
  getDashboard() {
    return this.storageService.getDashboard();
  }

  @Get('lockers')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List all lockers with boxes' })
  getLockers() {
    return this.storageService.getLockers();
  }

  @Get('lockers/:code')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get locker detail with boxes' })
  @ApiParam({ name: 'code', example: 'A' })
  getLocker(@Param('code') code: string) {
    return this.storageService.getLocker(code);
  }

  @Get('boxes/search')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Search storage boxes' })
  search(@Query() query: StorageSearchQueryDto) {
    return this.storageService.search(query);
  }

  @Get('lockers/:code/available')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List available boxes for a locker' })
  getAvailable(@Param('code') code: string) {
    return this.storageService.getAvailableBoxes(code);
  }

  @Get('boxes/:code')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get storage box detail' })
  getBox(@Param('code') code: string) {
    return this.storageService.getBox(code);
  }

  @Get('orders/:orderId')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get order storage assignment and history' })
  getOrderStorage(@Param('orderId', ParseUUIDPipe) orderId: string) {
    return this.storageService.getOrderStorage(orderId);
  }

  @Post('orders/:orderId/assign')
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Assign order to storage box' })
  assign(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: AssignStorageDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.storageService.assign(orderId, dto, user.employeeId);
  }

  @Patch('orders/:orderId/move')
  @Roles(...WRITE_ROLES)
  @ApiOperation({ summary: 'Move order to another storage box' })
  move(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: MoveStorageDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    return this.storageService.move(orderId, dto, user.employeeId);
  }
}
