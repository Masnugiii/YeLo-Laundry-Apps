import {
  Body,
  Controller,
  Get,
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
  CreatePaymentMethodDto,
  UpdatePaymentMethodDto,
} from './master-data.dto';
import { PaymentMethodService } from './payment-method.service';

@ApiTags('Payment Methods')
@ApiBearerAuth('access-token')
@Permissions(PERMISSIONS.SETTINGS)
@Roles(ROLES.OWNER, ROLES.MANAGER)
@Controller('payment-methods')
export class PaymentMethodController {
  constructor(private readonly paymentMethodService: PaymentMethodService) {}

  @Get()
  @ApiOperation({ summary: 'List payment methods' })
  async list(@Query('includeInactive') includeInactive?: string) {
    const data = await this.paymentMethodService.list(
      includeInactive === 'true',
    );
    return {
      success: true,
      message: 'Payment methods retrieved successfully',
      data,
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get payment method detail' })
  async getOne(@Param('id', ParseUUIDPipe) id: string) {
    const data = await this.paymentMethodService.getById(id);
    return {
      success: true,
      message: 'Payment method retrieved successfully',
      data,
    };
  }

  @Post()
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Create payment method (OWNER only)' })
  async create(
    @Body() dto: CreatePaymentMethodDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.paymentMethodService.create(dto, user.employeeId);
    return {
      success: true,
      message: 'Payment method created successfully',
      data,
    };
  }

  @Patch(':id')
  @Roles(ROLES.OWNER)
  @UseGuards(OwnerWriteGuard)
  @ApiOperation({ summary: 'Update payment method (OWNER only)' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePaymentMethodDto,
    @CurrentUser() user: AuthenticatedEmployee,
  ) {
    const data = await this.paymentMethodService.update(
      id,
      dto,
      user.employeeId,
    );
    return {
      success: true,
      message: 'Payment method updated successfully',
      data,
    };
  }
}
