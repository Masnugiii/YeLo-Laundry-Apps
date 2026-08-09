import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { normalizePhone } from '../auth/utils/phone.util';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { ChangePasswordDto } from './dto/change-password.dto';
import { ProfileResponseDto } from './dto/profile-response.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { EmployeeRepository } from './employee.repository';
import { toProfileResponse } from './profile.mapper';

const BCRYPT_ROUNDS = 10;

@Injectable()
export class ProfileService {
  private readonly logger = new Logger(ProfileService.name);

  constructor(private readonly employeeRepository: EmployeeRepository) {}

  async getProfile(
    employeeId: string,
  ): Promise<ApiSuccessResponse<ProfileResponseDto>> {
    const employee = await this.employeeRepository.findByIdWithRoles(employeeId);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }

    return {
      success: true,
      message: 'Profile retrieved successfully',
      data: toProfileResponse(employee),
    };
  }

  async updateProfile(
    employeeId: string,
    dto: UpdateProfileDto,
  ): Promise<ApiSuccessResponse<ProfileResponseDto>> {
    const existing = await this.employeeRepository.findByIdWithRoles(employeeId);

    if (!existing) {
      throw new NotFoundException('Employee not found');
    }

    const phone = dto.phone ? normalizePhone(dto.phone) : undefined;
    const email =
      dto.email === undefined
        ? undefined
        : dto.email
          ? dto.email.trim().toLowerCase()
          : null;

    await this.ensureUniqueFields(
      { phone, email: email ?? undefined },
      employeeId,
    );

    await this.employeeRepository.update(employeeId, {
      ...(dto.fullName !== undefined && { fullName: dto.fullName }),
      ...(phone !== undefined && { phone }),
      ...(dto.email !== undefined && { email }),
      ...(dto.avatar !== undefined && { photoUrl: dto.avatar }),
    });

    const employee = await this.employeeRepository.findByIdWithRoles(employeeId);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }

    this.logger.log(`Profile updated for employee ${employeeId}`);

    return {
      success: true,
      message: 'Profile updated successfully',
      data: toProfileResponse(employee),
    };
  }

  async changePassword(
    employeeId: string,
    dto: ChangePasswordDto,
  ): Promise<ApiSuccessResponse<null>> {
    const employee = await this.employeeRepository.findCredentialsById(employeeId);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }

    const isCurrentPasswordValid = await bcrypt.compare(
      dto.currentPassword,
      employee.passwordHash,
    );

    if (!isCurrentPasswordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    const isSamePassword = await bcrypt.compare(
      dto.newPassword,
      employee.passwordHash,
    );

    if (isSamePassword) {
      throw new BadRequestException(
        'New password cannot be the same as current password',
      );
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS);

    await this.employeeRepository.update(employeeId, { passwordHash });

    this.logger.log(`Password changed for employee ${employeeId}`);

    return {
      success: true,
      message: 'Password changed successfully',
      data: null,
    };
  }

  async resetPassword(
    employeeId: string,
    dto: ResetPasswordDto,
  ): Promise<ApiSuccessResponse<null>> {
    const employee = await this.employeeRepository.findCredentialsById(employeeId);

    if (!employee) {
      throw new NotFoundException('Employee not found');
    }

    const isSamePassword = await bcrypt.compare(
      dto.newPassword,
      employee.passwordHash,
    );

    if (isSamePassword) {
      throw new BadRequestException(
        'New password cannot be the same as current password',
      );
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, BCRYPT_ROUNDS);

    await this.employeeRepository.update(employeeId, { passwordHash });

    this.logger.log(`Password reset for employee ${employeeId}`);

    return {
      success: true,
      message: 'Password reset successfully',
      data: null,
    };
  }

  private async ensureUniqueFields(
    fields: { phone?: string; email?: string },
    excludeId: string,
  ): Promise<void> {
    if (fields.phone) {
      const existing = await this.employeeRepository.findByPhone(
        fields.phone,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Phone number already exists');
      }
    }

    if (fields.email) {
      const existing = await this.employeeRepository.findByEmail(
        fields.email,
        excludeId,
      );

      if (existing) {
        throw new ConflictException('Email already exists');
      }
    }
  }
}
