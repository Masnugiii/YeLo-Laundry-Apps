import { Body, Controller, Get, HttpCode, HttpStatus, Patch, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthenticatedEmployee } from '../auth/interfaces/jwt-payload.interface';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ProfileResponseDto } from './dto/profile-response.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { ProfileService } from './profile.service';

@ApiTags('Profile')
@ApiBearerAuth('access-token')
@Controller('profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Get()
  @ApiOperation({ summary: 'Get current authenticated employee profile' })
  @ApiResponse({
    status: 200,
    description: 'Profile retrieved successfully',
    schema: {
      example: {
        success: true,
        message: 'Profile retrieved successfully',
        data: {
          id: '550e8400-e29b-41d4-a716-446655440000',
          employeeCode: 'EMP0001',
          fullName: 'Owner',
          phone: '081234567890',
          email: 'owner@example.com',
          avatar: 'https://cdn.example.com/avatars/owner.jpg',
          roles: ['OWNER'],
          permissions: ['dashboard', 'orders'],
          status: 'ACTIVE',
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-08-08T06:00:00.000Z',
          lastLoginAt: '2026-08-08T06:30:00.000Z',
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  getProfile(
    @CurrentUser() user: AuthenticatedEmployee,
  ): Promise<ApiSuccessResponse<ProfileResponseDto>> {
    return this.profileService.getProfile(user.employeeId);
  }

  @Patch()
  @ApiOperation({ summary: 'Update own profile' })
  @ApiBody({ type: UpdateProfileDto })
  @ApiResponse({ status: 200, description: 'Profile updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 409, description: 'Phone or email already exists' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  updateProfile(
    @CurrentUser() user: AuthenticatedEmployee,
    @Body() dto: UpdateProfileDto,
  ): Promise<ApiSuccessResponse<ProfileResponseDto>> {
    return this.profileService.updateProfile(user.employeeId, dto);
  }

  @Post('change-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Change own password' })
  @ApiBody({
    type: ChangePasswordDto,
    examples: {
      default: {
        summary: 'Change password',
        value: {
          currentPassword: 'admin123',
          newPassword: 'NewPassword123!',
          confirmPassword: 'NewPassword123!',
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Password changed successfully' })
  @ApiResponse({ status: 400, description: 'New password same as current' })
  @ApiResponse({ status: 401, description: 'Current password is incorrect' })
  @ApiResponse({ status: 422, description: 'Validation error' })
  changePassword(
    @CurrentUser() user: AuthenticatedEmployee,
    @Body() dto: ChangePasswordDto,
  ): Promise<ApiSuccessResponse<null>> {
    return this.profileService.changePassword(user.employeeId, dto);
  }
}
