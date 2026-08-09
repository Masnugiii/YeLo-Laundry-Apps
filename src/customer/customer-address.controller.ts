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
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ROLES } from '../auth/constants/roles.constant';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { PERMISSIONS } from '../auth/constants/permissions.constant';
import { AllowCustomerActor } from './decorators/allow-customer-actor.decorator';
import { CustomerSelfGuard } from './guards/customer-self.guard';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CustomerAddressItem } from './customer-address.mapper';
import { CustomerAddressService } from './customer-address.service';
import { CreateCustomerAddressDto } from './dto/create-customer-address.dto';
import { CustomerAddressQueryDto } from './dto/customer-address-query.dto';
import { UpdateCustomerAddressDto } from './dto/update-customer-address.dto';

const ADDRESS_RESPONSE_EXAMPLE = {
  id: 'aa0e8400-e29b-41d4-a716-446655440006',
  customerId: '990e8400-e29b-41d4-a716-446655440005',
  label: 'Rumah',
  recipientName: 'Nugroho Prasetyo',
  phone: '+6281234567890',
  address: 'Jl. Melati No.1',
  fullAddress: 'Jl. Melati No.1, Mayangan, Probolinggo, Jawa Timur, 67217',
  province: 'Jawa Timur',
  city: 'Probolinggo',
  district: 'Mayangan',
  postalCode: '67217',
  coordinates: {
    latitude: -7.756,
    longitude: 113.215,
  },
  isDefault: true,
  notes: 'Pagar hitam',
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

@ApiTags('Customer Addresses')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.CUSTOMERS)
@Controller('customers/:customerId/addresses')
export class CustomerAddressController {
  constructor(private readonly addressService: CustomerAddressService) {}

  @Get()
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...VIEW_ROLES)
  @ApiOperation({
    summary: 'List customer addresses',
    description:
      'Returns all active (non-deleted) addresses for a customer. Supports filtering by label, recipient name, and phone.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer addresses retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer addresses retrieved successfully',
        data: [ADDRESS_RESPONSE_EXAMPLE],
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  findAll(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Query() query: CustomerAddressQueryDto,
  ): Promise<ApiSuccessResponse<CustomerAddressItem[]>> {
    return this.addressService.findAll(customerId, query);
  }

  @Get(':addressId')
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...VIEW_ROLES)
  @ApiOperation({ summary: 'Get a customer address by ID' })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'addressId', description: 'Address UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer address retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer address retrieved successfully',
        data: ADDRESS_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Customer or address not found' })
  findOne(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('addressId', ParseUUIDPipe) addressId: string,
  ): Promise<ApiSuccessResponse<CustomerAddressItem>> {
    return this.addressService.findOne(customerId, addressId);
  }

  @Post()
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add a customer address',
    description:
      'Creates a new address. When isDefault is true, all other addresses for this customer are unset as default.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiBody({
    type: CreateCustomerAddressDto,
    examples: {
      default: {
        summary: 'Home address',
        value: {
          label: 'Rumah',
          recipientName: 'Nugroho Prasetyo',
          phone: '081234567890',
          address: 'Jl. Melati No.1',
          province: 'Jawa Timur',
          city: 'Probolinggo',
          district: 'Mayangan',
          postalCode: '67217',
          latitude: -7.756,
          longitude: 113.215,
          isDefault: true,
          notes: 'Pagar hitam',
        },
      },
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Customer address created successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer address created successfully',
        data: ADDRESS_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Operator is view-only' })
  @ApiResponse({ status: 404, description: 'Customer not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  create(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Body() dto: CreateCustomerAddressDto,
  ): Promise<ApiSuccessResponse<CustomerAddressItem>> {
    return this.addressService.create(customerId, dto);
  }

  @Patch(':addressId')
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...WRITE_ROLES)
  @ApiOperation({
    summary: 'Update a customer address',
    description:
      'Partial update. Setting isDefault to true clears the default flag on all other addresses.',
  })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'addressId', description: 'Address UUID' })
  @ApiBody({
    type: UpdateCustomerAddressDto,
    examples: {
      default: {
        summary: 'Update default flag',
        value: {
          isDefault: true,
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Customer address updated successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer address updated successfully',
        data: ADDRESS_RESPONSE_EXAMPLE,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Operator is view-only' })
  @ApiResponse({ status: 404, description: 'Customer or address not found' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  update(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('addressId', ParseUUIDPipe) addressId: string,
    @Body() dto: UpdateCustomerAddressDto,
  ): Promise<ApiSuccessResponse<CustomerAddressItem>> {
    return this.addressService.update(customerId, addressId, dto);
  }

  @Delete(':addressId')
  @AllowCustomerActor()
  @UseGuards(CustomerSelfGuard)
  @Roles(...WRITE_ROLES)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Soft delete a customer address' })
  @ApiParam({ name: 'customerId', description: 'Customer UUID' })
  @ApiParam({ name: 'addressId', description: 'Address UUID' })
  @ApiResponse({
    status: 200,
    description: 'Customer address deleted successfully',
    schema: {
      example: {
        success: true,
        message: 'Customer address deleted successfully',
        data: null,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden — Operator is view-only' })
  @ApiResponse({ status: 404, description: 'Customer or address not found' })
  remove(
    @Param('customerId', ParseUUIDPipe) customerId: string,
    @Param('addressId', ParseUUIDPipe) addressId: string,
  ): Promise<ApiSuccessResponse<null>> {
    return this.addressService.remove(customerId, addressId);
  }
}
