import {
  Body,
  Controller,
  ForbiddenException,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Post,
  Req,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { isAuthenticatedCustomer } from '../customer/interfaces/authenticated-customer.interface';
import { AuthService } from './auth.service';
import { CurrentUser } from './decorators/current-user.decorator';
import { CustomerRegisterDto } from './dto/customer-register.dto';
import {
  CustomerAuthResponseDto,
  SendOtpResponseDto,
} from './dto/customer-auth-response.dto';
import {
  CustomerProfileResponseDto,
  UpdateCustomerProfileDto,
} from './dto/customer-profile.dto';
import { LoginDto } from './dto/login.dto';
import { LoginResponseDto } from './dto/login-response.dto';
import { ProfileResponseDto } from './dto/profile-response.dto';
import { RefreshResponseDto } from './dto/refresh-response.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { AuthenticatedEmployee } from './interfaces/jwt-payload.interface';
import { OtpService } from './otp/otp.service';
import { Request } from 'express';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly otpService: OtpService,
  ) {}

  @Public()
  @Get('ping')
  @ApiOperation({ summary: 'Verify authentication module readiness' })
  @ApiResponse({
    status: 200,
    description: 'Authentication module is ready',
    schema: {
      example: {
        success: true,
        message: 'Authentication module is ready.',
      },
    },
  })
  ping() {
    return this.authService.ping();
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login with phone number and password' })
  @ApiBody({
    type: LoginDto,
    examples: {
      owner: {
        summary: 'Default owner account',
        value: {
          phone: '081234567890',
          password: 'admin123',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Login successful',
    schema: {
      example: {
        success: true,
        message: 'Login successful',
        data: {
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          user: {
            id: '550e8400-e29b-41d4-a716-446655440000',
            employeeCode: 'EMP0001',
            fullName: 'Owner',
            phone: '081234567890',
            roles: ['OWNER'],
          },
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Invalid phone number or password' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  login(
    @Body() dto: LoginDto,
  ): Promise<ApiSuccessResponse<LoginResponseDto>> {
    return this.authService.login(dto);
  }

  @Get('profile')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get current authenticated profile' })
  @ApiResponse({ status: 200, description: 'Profile loaded successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  getCurrentProfile(
    @Req() request: Request,
  ): Promise<
    ApiSuccessResponse<ProfileResponseDto | CustomerProfileResponseDto>
  > {
    if (isAuthenticatedCustomer(request.user)) {
      return this.otpService.getCustomerProfile(request.user.customerId);
    }

    return this.authService.getProfile(
      (request.user as AuthenticatedEmployee).employeeId,
    );
  }

  @Patch('profile')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Update authenticated customer profile' })
  @ApiBody({ type: UpdateCustomerProfileDto })
  updateProfile(
    @Req() request: Request,
    @Body() dto: UpdateCustomerProfileDto,
  ): Promise<ApiSuccessResponse<CustomerProfileResponseDto>> {
    if (!isAuthenticatedCustomer(request.user)) {
      throw new ForbiddenException('Customer authentication required');
    }

    return this.otpService.updateCustomerProfile(
      request.user.customerId,
      dto,
    );
  }

  @Public()
  @Post('otp/send')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Send OTP for customer login or registration' })
  @ApiBody({ type: SendOtpDto })
  sendOtp(
    @Body() dto: SendOtpDto,
  ): Promise<ApiSuccessResponse<SendOtpResponseDto>> {
    return this.otpService.sendOtp(dto);
  }

  @Public()
  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP and login customer' })
  @ApiBody({ type: VerifyOtpDto })
  verifyOtp(
    @Body() dto: VerifyOtpDto,
  ): Promise<ApiSuccessResponse<CustomerAuthResponseDto>> {
    return this.otpService.verifyOtp(dto);
  }

  @Public()
  @Post('customer/register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Register new customer with OTP verification' })
  @ApiBody({ type: CustomerRegisterDto })
  registerCustomer(
    @Body() dto: CustomerRegisterDto,
  ): Promise<ApiSuccessResponse<CustomerAuthResponseDto>> {
    return this.otpService.registerCustomer(dto);
  }

  @Get('me')
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get authenticated employee profile' })
  @ApiResponse({
    status: 200,
    description: 'Profile loaded successfully',
    schema: {
      example: {
        success: true,
        message: 'Profile loaded successfully',
        data: {
          id: '550e8400-e29b-41d4-a716-446655440000',
          employeeCode: 'EMP0001',
          fullName: 'Owner',
          phone: '081234567890',
          roles: ['OWNER'],
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  getProfile(
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ProfileResponseDto>> {
    return this.authService.getProfile(user.employeeId);
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token using a valid refresh token' })
  @ApiBody({
    type: RefreshTokenDto,
    examples: {
      default: {
        summary: 'Refresh token',
        value: {
          refreshToken:
            '550e8400-e29b-41d4-a716-446655440000.a1b2c3d4e5f6789...',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Token refreshed successfully',
    schema: {
      example: {
        success: true,
        message: 'Token refreshed successfully',
        data: {
          accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          refreshToken:
            '550e8400-e29b-41d4-a716-446655440000.b2c3d4e5f6789...',
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  refresh(
    @Body() dto: RefreshTokenDto,
  ): Promise<ApiSuccessResponse<RefreshResponseDto>> {
    return this.authService.refresh(dto.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Logout and invalidate all active sessions' })
  @ApiResponse({
    status: 200,
    description: 'Logout successful',
    schema: {
      example: {
        success: true,
        message: 'Logout successful',
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  logout(
    @Req() request: Request,
  ): Promise<ApiSuccessResponse<undefined>> {
    if (isAuthenticatedCustomer(request.user)) {
      return Promise.resolve({
        success: true,
        message: 'Logout successful',
      });
    }

    return this.authService.logout(
      (request.user as AuthenticatedEmployee).employeeId,
    );
  }
}
