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
  GenerateInvoiceDto,
  InvoiceQueryDto,
  SendInvoiceDto,
} from './dto/invoice.dto';
import {
  InvoiceResponse,
  InvoiceService,
  PaginatedInvoices,
} from './invoice.service';

const VIEW_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR] as const;
const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;

const INVOICE_EXAMPLE = {
  invoiceNumber: 'INV-20260808-000001',
  orderId: 'ee0e8400-e29b-41d4-a716-446655440010',
  orderNumber: 'YL-20260808-000001',
  amount: 28000,
  status: 'PAID',
  generatedAt: '2026-08-08T07:30:00.000Z',
  sentAt: null,
};

@ApiTags('Invoices')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.FINANCE)
@Controller('invoices')
export class InvoiceController {
  constructor(private readonly invoiceService: InvoiceService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List invoices' })
  @ApiResponse({
    status: 200,
    description: 'Invoices retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Invoices retrieved successfully',
        data: {
          items: [INVOICE_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: InvoiceQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedInvoices>> {
    return this.invoiceService.findAll(query);
  }

  @Get(':id')
  @Roles(...VIEW_ROLES)
  @ApiOperation({
    summary: 'Get invoice by order ID',
    description: 'Invoice is linked to order; pass order UUID as id.',
  })
  @ApiParam({ name: 'id', description: 'Order UUID' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<InvoiceResponse>> {
    return this.invoiceService.findOne(id);
  }

  @Post('generate')
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Generate invoice for an order' })
  @ApiBody({
    type: GenerateInvoiceDto,
    examples: {
      default: {
        summary: 'Generate invoice',
        value: { orderId: 'ee0e8400-e29b-41d4-a716-446655440010' },
      },
    },
  })
  generate(
    @Body() dto: GenerateInvoiceDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<InvoiceResponse>> {
    return this.invoiceService.generate(dto, user.employeeId);
  }

  @Post('send')
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark invoice as sent' })
  @ApiBody({
    type: SendInvoiceDto,
    examples: {
      default: {
        summary: 'Send invoice',
        value: {
          orderId: 'ee0e8400-e29b-41d4-a716-446655440010',
          email: 'andi@email.com',
        },
      },
    },
  })
  send(
    @Body() dto: SendInvoiceDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<InvoiceResponse>> {
    return this.invoiceService.send(dto, user.employeeId);
  }
}
