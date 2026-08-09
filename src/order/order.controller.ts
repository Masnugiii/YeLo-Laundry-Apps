import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Res,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { OrderStatus } from '@prisma/client';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CancelOrderDto } from './dto/cancel-order.dto';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrderQueryDto } from './dto/order-query.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import {
  OrderDetail,
  OrderStatistics,
  PaginatedOrders,
} from './order.mapper';
import { OrderService } from './order.service';
import type { Response } from 'express';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;

const ORDER_DETAIL_EXAMPLE = {
  id: 'ee0e8400-e29b-41d4-a716-446655440010',
  orderNumber: 'YL-20260808-000001',
  queueNumber: 'YL-0001',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  customerName: 'Andi Wijaya',
  customerPhone: '+6281122334455',
  orderStatus: OrderStatus.CREATED,
  paymentStatus: 'UNPAID',
  subtotal: 28000,
  discount: 0,
  tax: 0,
  serviceFee: 0,
  grandTotal: 28000,
  pickupRequired: false,
  deliveryRequired: false,
  estimatedFinishDate: '2026-08-10T17:00:00.000Z',
  completedDate: null,
  orderDate: '2026-08-08T03:30:00.000Z',
  createdBy: {
    id: '660e8400-e29b-41d4-a716-446655440001',
    fullName: 'Admin Owner',
    employeeCode: 'EMP0001',
  },
  createdAt: '2026-08-08T03:30:00.000Z',
};

@ApiTags('Orders')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.ORDERS)
@Controller('orders')
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @Get('statistics')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get order statistics dashboard metrics' })
  @ApiResponse({
    status: 200,
    description: 'Order statistics retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Order statistics retrieved successfully',
        data: {
          totalOrders: 120,
          todayOrders: 8,
          completedOrders: 95,
          cancelledOrders: 5,
          revenueToday: 1250000,
          revenueThisMonth: 28500000,
          averageTicket: 300000,
        },
      },
    },
  })
  getStatistics(): Promise<ApiSuccessResponse<OrderStatistics>> {
    return this.orderService.getStatistics();
  }

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List orders with search, filters, and pagination' })
  @ApiResponse({
    status: 200,
    description: 'Orders retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Orders retrieved successfully',
        data: {
          items: [ORDER_DETAIL_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: OrderQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedOrders>> {
    return this.orderService.findAll(query);
  }

  @Get('export')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Export orders as CSV' })
  @Header('Content-Type', 'text/csv; charset=utf-8')
  @Header('Content-Disposition', 'attachment; filename="orders.csv"')
  async exportOrders(
    @Query() query: OrderQueryDto,
    @Res() res: Response,
  ): Promise<void> {
    const csv = await this.orderService.exportOrders(query);
    res.send(csv);
  }

  @Post()
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new laundry order' })
  @ApiBody({
    type: CreateOrderDto,
    examples: {
      default: {
        summary: 'Create order with one laundry item',
        value: {
          customerId: '990e8400-e29b-41d4-a716-446655440005',
          estimatedFinishDate: '2026-08-10T17:00:00.000Z',
          items: [
            {
              serviceId: 'dd0e8400-e29b-41d4-a716-446655440009',
              quantity: 3.5,
              notes: 'Jangan pakai pewangi',
            },
          ],
          discountAmount: 0,
          pickupRequired: false,
          deliveryRequired: false,
          notes: 'Pelanggan rutin',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Order created successfully',
    schema: {
      example: {
        success: true,
        message: 'Order created successfully',
        data: ORDER_DETAIL_EXAMPLE,
      },
    },
  })
  create(
    @Body() dto: CreateOrderDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    return this.orderService.create(dto, user.employeeId);
  }

  @Get(':id')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get order detail with timeline and items' })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiResponse({
    status: 200,
    description: 'Order retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Order retrieved successfully',
        data: ORDER_DETAIL_EXAMPLE,
      },
    },
  })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    return this.orderService.findOne(id);
  }

  @Patch(':id')
  @Roles(...WRITE_ROLES)
  @ApiOperation({
    summary: 'Update order fields or status',
    description:
      'Supports notes, fulfillment fields, financial adjustments, and status transitions.',
  })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiBody({
    type: UpdateOrderDto,
    examples: {
      notes: {
        summary: 'Update notes only',
        value: { notes: 'Pelanggan minta cepat' },
      },
      status: {
        summary: 'Update status',
        value: {
          status: OrderStatus.WAITING_BINATU,
          statusNotes: 'Payment confirmed',
        },
      },
    },
  })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateOrderDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    return this.orderService.update(id, dto, user.employeeId);
  }

  @Delete(':id')
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Cancel order (soft delete)' })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  @ApiBody({
    type: CancelOrderDto,
    examples: {
      default: {
        summary: 'Cancel with reason',
        value: { reason: 'Customer request cancellation' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Order cancelled successfully',
    schema: {
      example: {
        success: true,
        message: 'Order cancelled successfully',
        data: {
          ...ORDER_DETAIL_EXAMPLE,
          orderStatus: OrderStatus.CANCELLED,
        },
      },
    },
  })
  cancel(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CancelOrderDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<OrderDetail>> {
    return this.orderService.cancel(id, dto, user.employeeId);
  }
}
