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
  CsSummary,
  CsTicketDetail,
  CsTicketListItem,
} from './customer-service.mapper';
import { CustomerServiceService } from './customer-service.service';
import {
  CreateMessageDto,
  TicketQueryDto,
  UpdateTicketDto,
} from './dto/customer-service.dto';

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
  ROLES.BINATU,
  ROLES.DRIVER,
] as const;

const TICKET_EXAMPLE = {
  id: 'ff0e8400-e29b-41d4-a716-446655440070',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  customerName: 'Andi Wijaya',
  whatsappNumber: '081234567890',
  subject: 'Status laundry',
  messagePreview: 'Kak, laundry saya sudah sampai mana ya?',
  messageTime: '2026-08-08T08:00:00.000Z',
  category: 'TRACKING_ORDER',
  aiConfidence: 85,
  isUnread: true,
  status: 'OPEN',
  priority: 'NORMAL',
};

@ApiTags('Customer Service')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.CUSTOMER_SERVICE)
@Controller('customer-service')
export class CustomerServiceController {
  constructor(private readonly service: CustomerServiceService) {}

  @Get('summary')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get customer service dashboard summary' })
  @ApiResponse({
    status: 200,
    description: 'Summary retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer service summary retrieved successfully',
        data: {
          unreadMessages: 5,
          newComplaints: 2,
          orderQuestions: 3,
          completed: 10,
        },
      },
    },
  })
  getSummary(): Promise<ApiSuccessResponse<CsSummary>> {
    return this.service.getSummary();
  }

  @Get('tickets')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'List customer service tickets' })
  @ApiResponse({
    status: 200,
    description: 'Tickets retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer service tickets retrieved successfully',
        data: {
          items: [TICKET_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  findAll(
    @Query() query: TicketQueryDto,
  ): Promise<
    ApiSuccessResponse<{
      items: CsTicketListItem[];
      meta: { page: number; limit: number; total: number; totalPages: number };
    }>
  > {
    return this.service.findAll(query);
  }

  @Get('tickets/:id')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get customer service ticket detail' })
  @ApiParam({ name: 'id', description: 'Ticket UUID' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<CsTicketDetail>> {
    return this.service.findOne(id);
  }

  @Patch('tickets/:id')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER)
  @ApiOperation({ summary: 'Update ticket status or category' })
  @ApiParam({ name: 'id', description: 'Ticket UUID' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTicketDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<CsTicketDetail>> {
    return this.service.update(id, dto, user.employeeId);
  }

  @Post('tickets/:id/messages')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Reply to a customer service ticket' })
  @ApiParam({ name: 'id', description: 'Ticket UUID' })
  @ApiBody({
    type: CreateMessageDto,
    examples: {
      default: {
        summary: 'Employee reply',
        value: {
          message: 'Terima kasih sudah menghubungi kami. Laundry Anda sedang disetrika.',
        },
      },
    },
  })
  addMessage(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateMessageDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<CsTicketDetail>> {
    return this.service.addMessage(id, dto, user.employeeId);
  }
}
