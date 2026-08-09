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
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CustomerBusinessSummary,
  CustomerDetail,
  CustomerImportResult,
  CustomerSearchResult,
  PaginatedCustomers,
} from './customer.mapper';
import { CustomerService } from './customer.service';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { CustomerQueryDto } from './dto/customer-query.dto';
import { CustomerSearchDto } from './dto/customer-search.dto';
import { ImportCustomersDto } from './dto/import-customers.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { UpdateCustomerStatusDto } from './dto/update-customer-status.dto';
import type { Response } from 'express';

@ApiTags('Customers')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.CUSTOMERS)
@Controller('customers')
export class CustomerController {
  constructor(private readonly customerService: CustomerService) {}

  @Get('search')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @ApiOperation({ summary: 'Fast customer lookup for order creation' })
  @ApiResponse({ status: 200, description: 'Search results retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  search(
    @Query() query: CustomerSearchDto,
  ): Promise<ApiSuccessResponse<CustomerSearchResult[]>> {
    return this.customerService.search(query);
  }

  @Get()
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @ApiOperation({ summary: 'List customers with search, filter, sort, and pagination' })
  @ApiResponse({ status: 200, description: 'Customers retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  findAll(
    @Query() query: CustomerQueryDto,
  ): Promise<ApiSuccessResponse<PaginatedCustomers>> {
    return this.customerService.findAll(query);
  }

  @Get('export')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @ApiOperation({ summary: 'Export customers as CSV' })
  @Header('Content-Type', 'text/csv; charset=utf-8')
  @Header('Content-Disposition', 'attachment; filename="customers.csv"')
  async exportCustomers(
    @Query() query: CustomerQueryDto,
    @Res() res: Response,
  ): Promise<void> {
    const csv = await this.customerService.exportCustomers(query);
    res.send(csv);
  }

  @Post('import')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Import customers from validated rows' })
  importCustomers(
    @Body() dto: ImportCustomersDto,
  ): Promise<ApiSuccessResponse<CustomerImportResult>> {
    return this.customerService.importCustomers(dto);
  }

  @Post()
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register a new customer' })
  @ApiResponse({ status: 201, description: 'Customer created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 409, description: 'Duplicate phone or email' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  create(
    @Body() dto: CreateCustomerDto,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    return this.customerService.create(dto);
  }

  @Get(':id')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @ApiOperation({ summary: 'Get customer detail by ID' })
  @ApiParam({ name: 'id', description: 'Customer UUID' })
  @ApiResponse({ status: 200, description: 'Customer retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    return this.customerService.findOne(id);
  }

  @Get(':id/summary')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @ApiOperation({ summary: 'Get customer business summary' })
  getSummary(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<CustomerBusinessSummary>> {
    return this.customerService.getSummary(id);
  }

  @Patch(':id/status')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @ApiOperation({ summary: 'Activate or deactivate a customer' })
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCustomerStatusDto,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    return this.customerService.updateStatus(id, dto);
  }

  @Patch(':id')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @ApiOperation({ summary: 'Update customer profile' })
  @ApiParam({ name: 'id', description: 'Customer UUID' })
  @ApiResponse({ status: 200, description: 'Customer updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  @ApiResponse({ status: 409, description: 'Duplicate phone or email' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCustomerDto,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    return this.customerService.update(id, dto);
  }

  @Delete(':id')
  @Roles(ROLES.OWNER, ROLES.MANAGER, ROLES.CASHIER, ROLES.OPERATOR)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete a customer' })
  @ApiParam({ name: 'id', description: 'Customer UUID' })
  @ApiResponse({ status: 200, description: 'Customer deleted successfully' })
  @ApiResponse({ status: 400, description: 'Customer has open orders' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<null>> {
    return this.customerService.remove(id);
  }

  @Post(':id/restore')
  @Roles(ROLES.OWNER, ROLES.MANAGER)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Restore a soft-deleted customer' })
  @ApiParam({ name: 'id', description: 'Customer UUID' })
  @ApiResponse({ status: 200, description: 'Customer restored successfully' })
  @ApiResponse({ status: 400, description: 'Customer is not deleted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  @ApiResponse({ status: 409, description: 'Duplicate phone or email' })
  restore(
    @Param('id', ParseUUIDPipe) id: string,
  ): Promise<ApiSuccessResponse<CustomerDetail>> {
    return this.customerService.restore(id);
  }
}
