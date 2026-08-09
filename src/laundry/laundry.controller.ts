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
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  LaundryOrderQueryDto,
  ProductionActionDto,
  QualityCheckDto,
} from './dto/laundry.dto';
import {
  LaundryDashboard,
  LaundryOrderDetail,
  LaundryOrderListItem,
  PaginatedLaundryOrders,
} from './laundry.mapper';
import { LaundryService } from './laundry.service';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const PRODUCTION_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.BINATU] as const;

const ORDER_EXAMPLE = {
  orderId: 'ee0e8400-e29b-41d4-a716-446655440010',
  orderNumber: 'YL-20260808-000001',
  queueNumber: 'YL-0001',
  customerName: 'Andi Wijaya',
  customerPhone: '+6281122334455',
  productionStatus: 'WASHING',
  priority: 'NORMAL',
  receivedAt: '2026-08-08T01:00:00.000Z',
};

@ApiTags('Laundry Production')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.IRONING)
@Controller('laundry')
export class LaundryController {
  constructor(private readonly laundryService: LaundryService) {}

  @Get('dashboard')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get production dashboard metrics' })
  @ApiResponse({
    status: 200,
    description: 'Production dashboard retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Production dashboard retrieved successfully',
        data: {
          waitingWashing: 5,
          currentlyWashing: 2,
          waitingDrying: 3,
          currentlyDrying: 1,
          waitingIroning: 4,
          currentlyIroning: 2,
          qualityCheck: 1,
          readyForPickup: 6,
          completedToday: 8,
          averageProductionTimeMinutes: 185,
        },
      },
    },
  })
  getDashboard(): Promise<ApiSuccessResponse<LaundryDashboard>> {
    return this.laundryService.getDashboard();
  }

  @Get('queues/washing')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get washing production queue' })
  getWashingQueue(): Promise<ApiSuccessResponse<LaundryOrderListItem[]>> {
    return this.laundryService.getQueue(['WAITING_WASH', 'WASHING']);
  }

  @Get('queues/drying')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get drying production queue' })
  getDryingQueue(): Promise<ApiSuccessResponse<LaundryOrderListItem[]>> {
    return this.laundryService.getQueue(['WAITING_DRY', 'DRYING']);
  }

  @Get('queues/ironing')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get ironing production queue' })
  getIroningQueue(): Promise<ApiSuccessResponse<LaundryOrderListItem[]>> {
    return this.laundryService.getQueue(['WAITING_IRON', 'IRONING']);
  }

  @Get('orders')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List production orders with filters' })
  @ApiResponse({
    status: 200,
    description: 'Production orders retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Production orders retrieved successfully',
        data: {
          items: [ORDER_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findOrders(
    @Query() query: LaundryOrderQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedLaundryOrders>> {
    return this.laundryService.findOrders(query);
  }

  @Get('orders/:orderId')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get production order detail' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  findOrderDetail(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.findOrderDetail(orderId, user.employeeId);
  }

  @Post('orders/:orderId/start-washing')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start washing stage' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  startWashing(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.runProductionAction(
      orderId,
      'start-washing',
      dto,
      user.employeeId,
    );
  }

  @Post('orders/:orderId/finish-washing')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Finish washing stage' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  finishWashing(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.runProductionAction(
      orderId,
      'finish-washing',
      dto,
      user.employeeId,
    );
  }

  @Post('orders/:orderId/start-drying')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start drying stage' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  startDrying(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.runProductionAction(
      orderId,
      'start-drying',
      dto,
      user.employeeId,
    );
  }

  @Post('orders/:orderId/finish-drying')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Finish drying stage' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  finishDrying(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.runProductionAction(
      orderId,
      'finish-drying',
      dto,
      user.employeeId,
    );
  }

  @Post('orders/:orderId/start-ironing')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start ironing stage' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  startIroning(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.runProductionAction(
      orderId,
      'start-ironing',
      dto,
      user.employeeId,
    );
  }

  @Post('orders/:orderId/finish-ironing')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Finish ironing stage' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  finishIroning(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.runProductionAction(
      orderId,
      'finish-ironing',
      dto,
      user.employeeId,
    );
  }

  @Post('orders/:orderId/quality-check')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Perform quality control check' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({
    type: QualityCheckDto,
    examples: {
      pass: {
        summary: 'Pass quality check',
        value: { passed: true, notes: 'No stain remaining.' },
      },
      rework: {
        summary: 'Fail and send to rework',
        value: {
          passed: false,
          reworkStage: 'WAITING_WASH',
          reason: 'Stain found on collar',
        },
      },
    },
  })
  qualityCheck(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: QualityCheckDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.qualityCheck(orderId, dto, user.employeeId);
  }

  @Post('orders/:orderId/ready')
  @Roles(...PRODUCTION_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark order ready for pickup' })
  @ApiParam({ name: 'orderId', description: 'Order UUID' })
  @ApiBody({ type: ProductionActionDto })
  markReady(
    @Param('orderId', ParseUUIDPipe) orderId: string,
    @Body() dto: ProductionActionDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<LaundryOrderDetail>> {
    return this.laundryService.markReady(orderId, dto, user.employeeId);
  }
}
