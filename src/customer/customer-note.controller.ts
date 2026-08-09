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
import { ROLES } from '../auth/constants/roles.constant';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CustomerNoteItem,
  PaginatedCustomerNotes,
} from './customer-note.mapper';
import { CustomerNoteService } from './customer-note.service';
import { CreateCustomerNoteDto } from './dto/create-customer-note.dto';
import { CustomerNoteQueryDto } from './dto/customer-note-query.dto';
import { UpdateCustomerNoteDto } from './dto/update-customer-note.dto';
import { CustomerNoteCategory } from './utils/customer-note-meta.util';

const NOTE_RESPONSE_EXAMPLE = {
  id: 'cc0e8400-e29b-41d4-a716-446655440009',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  title: 'VIP Customer',
  note: 'Customer always requests perfume-free laundry.',
  category: CustomerNoteCategory.SERVICE,
  isPinned: true,
  createdBy: {
    id: '660e8400-e29b-41d4-a716-446655440001',
    fullName: 'Admin Owner',
    employeeCode: 'EMP0001',
  },
  createdAt: '2026-08-08T06:00:00.000Z',
  updatedAt: '2026-08-08T06:00:00.000Z',
};

const VIEW_ROLES = [
  ROLES.OWNER,
  ROLES.MANAGER,
  ROLES.CASHIER,
  ROLES.OPERATOR,
] as const;

const WRITE_ROLES = [ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER] as const;

const DELETE_ROLES = [ROLES.OWNER, ROLES.MANAGER] as const;

@ApiTags('Customer Notes')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.CUSTOMERS)
@Controller('customers/:customerId/notes')
export class CustomerNoteController {
  constructor(private readonly noteService: CustomerNoteService) {}

  @Get()
  @Roles(...VIEW_ROLES)
  @ApiOperation({
    summary: 'List internal customer notes',
    description:
      'Employee-only notes. Pinned notes appear first. Never exposed to Customer Mobile App APIs.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer notes retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer notes retrieved successfully',
        data: {
          items: [NOTE_RESPONSE_EXAMPLE],
          meta: { page: 1, limit: 20, total: 1, totalPages: 1 },
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  findAll(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Query() query: CustomerNoteQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedCustomerNotes>> {
    return this.noteService.findAll(customerId, query);
  }

  @Get(':noteId')
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get a customer note by ID' })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'noteId', description: 'Note UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer note retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer note retrieved successfully',
        data: NOTE_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or note not found' })
  findOne(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('noteId', ParseUUIDPipe) noteId: string,
  ): Promise<ApiSuccessResponse<CustomerNoteItem>> {
    return this.noteService.findOne(customerId, noteId);
  }

  @Post()
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create an internal customer note',
    description:
      'Records an employee-authored note. Not accessible from Customer Mobile App.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiBody({
    type: CreateCustomerNoteDto,
    examples: {
      default: {
        summary: 'VIP service note',
        value: {
          title: 'VIP Customer',
          note: 'Customer always requests perfume-free laundry.',
          category: CustomerNoteCategory.SERVICE,
          isPinned: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Customer note created successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer note created successfully',
        data: NOTE_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Operator is view-only' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  create(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Body() dto: CreateCustomerNoteDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<CustomerNoteItem>> {
    return this.noteService.create(customerId, dto, user.employeeId);
  }

  @Patch(':noteId')
  @Roles(...WRITE_ROLES)
  @ApiOperation({ summary: 'Update an internal customer note' })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'noteId', description: 'Note UUID' })
  @ApiBody({
    type: UpdateCustomerNoteDto,
    examples: {
      default: {
        summary: 'Pin existing note',
        value: {
          isPinned: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Customer note updated successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer note updated successfully',
        data: NOTE_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Operator is view-only' })
  @ApiResponse({ status: 404, description: 'Customer or note not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  update(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('noteId', ParseUUIDPipe) noteId: string,
    @Body() dto: UpdateCustomerNoteDto,
  ): Promise<ApiSuccessResponse<CustomerNoteItem>> {
    return this.noteService.update(customerId, noteId, dto);
  }

  @Delete(':noteId')
  @Roles(...DELETE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete a customer note' })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'noteId', description: 'Note UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer note deleted successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer note deleted successfully',
        data: null,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Owner and Manager only' })
  @ApiResponse({ status: 404, description: 'Customer or note not found' })
  remove(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('noteId', ParseUUIDPipe) noteId: string,
  ): Promise<ApiSuccessResponse<null>> {
    return this.noteService.remove(customerId, noteId);
  }
}
