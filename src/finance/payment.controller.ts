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
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { PaymentStatus } from '@prisma/client';
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CreatePaymentDto,
  PaymentQueryDto,
  RefundPaymentDto,
  UpdatePaymentDto,
} from './dto/payment.dto';
import { PaginatedPayments, PaymentResponse } from './payment.mapper';
import { PaymentService } from './payment.service';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR] as const;

const PAYMENT_EXAMPLE = {
  id: 'ff0e8400-e29b-41d4-a716-446655440020',
  referenceNumber: 'PAY-20260808-000001',
  orderId: 'ee0e8400-e29b-41d4-a716-446655440010',
  orderNumber: 'YL-20260808-000001',
  queueNumber: 'YL-0001',
  amount: 28000,
  refundedAmount: 0,
  netAmount: 28000,
  paymentStatus: PaymentStatus.PAID,
  displayStatus: 'PAID',
  paidAt: '2026-08-08T07:30:00.000Z',
  createdAt: '2026-08-08T07:30:00.000Z',
  updatedAt: '2026-08-08T07:30:00.000Z',
};

@ApiTags('Payments')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.FINANCE)
@Controller('payments')
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List payments with search and filters' })
  @ApiResponse({
    status: 200,
    description: 'Payments retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Payments retrieved successfully',
        data: {
          items: [PAYMENT_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: PaymentQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedPayments>> {
    return this.paymentService.findAll(query);
  }

  @Get(':id')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get payment detail' })
  @ApiParam({ name: 'id', description: 'Payment UUID' })
  @ApiResponse({
    status: 200,
    description: 'Payment retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Payment retrieved successfully',
        data: PAYMENT_EXAMPLE,
      },
    },
  })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    return this.paymentService.findOne(id);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a payment for an order' })
  @ApiBody({
    type: CreatePaymentDto,
    examples: {
      cash: {
        summary: 'Cash payment',
        value: {
          orderId: 'ee0e8400-e29b-41d4-a716-446655440010',
          paymentMethod: 'CASH',
          amount: 28000,
          paymentStatus: 'PAID',
          notes: 'Paid at counter',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Payment created successfully',
    schema: {
      example: {
        success: true,
        message: 'Payment created successfully',
        data: PAYMENT_EXAMPLE,
      },
    },
  })
  create(
    @Body() dto: CreatePaymentDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    return this.paymentService.create(dto, user.employeeId);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update payment' })
  @ApiParam({ name: 'id', description: 'Payment UUID' })
  @ApiBody({ type: UpdatePaymentDto })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePaymentDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    return this.paymentService.update(id, dto, user.employeeId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Void payment (soft delete)' })
  @ApiParam({ name: 'id', description: 'Payment UUID' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    return this.paymentService.remove(id, user.employeeId);
  }

  @Post(':id/refund')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refund payment (full or partial)' })
  @ApiParam({ name: 'id', description: 'Payment UUID' })
  @ApiBody({
    type: RefundPaymentDto,
    examples: {
      full: {
        summary: 'Full refund',
        value: {
          amount: 28000,
          reason: 'Customer cancelled order',
        },
      },
      partial: {
        summary: 'Partial refund',
        value: {
          amount: 5000,
          reason: 'Damaged item compensation',
        },
      },
    },
  })
  refund(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RefundPaymentDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<PaymentResponse>> {
    return this.paymentService.refund(id, dto, user.employeeId);
  }
}
