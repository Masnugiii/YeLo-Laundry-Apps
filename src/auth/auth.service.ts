import {
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { EmployeeStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { AuthRepository } from './auth.repository';
import { LoginDto } from './dto/login.dto';
import { LoginResponseDto } from './dto/login-response.dto';
import { ProfileResponseDto } from './dto/profile-response.dto';
import { RefreshResponseDto } from './dto/refresh-response.dto';
import { JwtPayload, EmployeeJwtPayload } from './interfaces/jwt-payload.interface';
import { OtpService } from './otp/otp.service';
import { normalizePhone } from './utils/phone.util';
import { extractRoles } from './utils/role.util';
import {
  extractSessionId,
  generateRefreshToken,
} from './utils/token.util';

const BCRYPT_ROUNDS = 10;

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly authRepository: AuthRepository,
    private readonly jwtService: JwtService,
    private readonly otpService: OtpService,
  ) {}

  ping() {
    return {
      success: true,
      message: 'Authentication module is ready.',
    };
  }

  async login(dto: LoginDto): Promise<ApiSuccessResponse<LoginResponseDto>> {
    const phone = normalizePhone(dto.phone);
    const employee = await this.authRepository.findEmployeeByPhone(phone);

    if (!employee) {
      this.logger.warn(`Login failed: employee not found for phone ${phone}`);
      throw new UnauthorizedException('Invalid phone number or password');
    }

    if (employee.status !== EmployeeStatus.active) {
      this.logger.warn(
        `Login failed: employee ${employee.id} is ${employee.status}`,
      );
      throw new UnauthorizedException('Invalid phone number or password');
    }

    const isPasswordValid = await bcrypt.compare(
      dto.password,
      employee.passwordHash,
    );

    if (!isPasswordValid) {
      this.logger.warn(`Login failed: invalid password for employee ${employee.id}`);
      throw new UnauthorizedException('Invalid phone number or password');
    }

    const roles = extractRoles(employee.employeeRoles);

    const payload: EmployeeJwtPayload = {
      actorType: 'employee',
      employeeId: employee.id,
      phone: employee.phone,
      roles,
    };

    const accessToken = this.jwtService.sign(payload);

    this.logger.log(`Login successful for employee ${employee.id}`);

    return {
      success: true,
      message: 'Login successful',
      data: {
        accessToken,
        user: {
          id: employee.id,
          employeeCode: employee.employeeCode,
          fullName: employee.fullName,
          phone: employee.phone,
          roles,
        },
      },
    };
  }

  async getProfile(
    employeeId: string,
  ): Promise<ApiSuccessResponse<ProfileResponseDto>> {
    const employee = await this.authRepository.findEmployeeById(employeeId);

    if (!employee) {
      throw new UnauthorizedException('Unauthorized');
    }

    const roles = extractRoles(employee.employeeRoles);

    this.logger.log(`Profile loaded for employee ${employeeId}`);

    return {
      success: true,
      message: 'Profile loaded successfully',
      data: {
        id: employee.id,
        employeeCode: employee.employeeCode,
        fullName: employee.fullName,
        phone: employee.phone,
        roles,
      },
    };
  }

  async refresh(
    refreshToken: string,
  ): Promise<ApiSuccessResponse<RefreshResponseDto>> {
    const decoded = this.jwtService.decode(refreshToken) as JwtPayload | null;

    if (decoded?.actorType === 'customer') {
      return this.otpService.refreshCustomerToken(refreshToken);
    }

    const sessionId = extractSessionId(refreshToken);

    if (!sessionId) {
      this.logger.warn('Refresh failed: malformed refresh token');
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const session = await this.authRepository.findSessionById(sessionId);

    if (!session || session.revokedAt) {
      this.logger.warn(`Refresh failed: session ${sessionId} not found or revoked`);
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    if (session.expiresAt < new Date()) {
      this.logger.warn(`Refresh failed: session ${sessionId} expired`);
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const isTokenValid = await bcrypt.compare(
      refreshToken,
      session.refreshTokenHash,
    );

    if (!isTokenValid) {
      this.logger.warn(`Refresh failed: hash mismatch for session ${sessionId}`);
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const employee = await this.authRepository.findEmployeeById(session.employeeId);

    if (!employee || employee.status !== EmployeeStatus.active) {
      this.logger.warn(`Refresh failed: employee ${session.employeeId} inactive`);
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const roles = extractRoles(employee.employeeRoles);
    const newRefreshToken = generateRefreshToken(sessionId);
    const newRefreshTokenHash = await bcrypt.hash(newRefreshToken, BCRYPT_ROUNDS);

    await this.authRepository.updateSessionRefreshTokenHash(
      sessionId,
      newRefreshTokenHash,
    );

    const accessToken = this.jwtService.sign({
      actorType: 'employee',
      employeeId: employee.id,
      phone: employee.phone,
      roles,
    } satisfies EmployeeJwtPayload);

    this.logger.log(`Refresh successful for employee ${employee.id}`);

    return {
      success: true,
      message: 'Token refreshed successfully',
      data: {
        accessToken,
        refreshToken: newRefreshToken,
      },
    };
  }

  async logout(employeeId: string): Promise<ApiSuccessResponse<undefined>> {
    await this.authRepository.revokeAllSessionsForEmployee(employeeId);

    this.logger.log(`Logout successful for employee ${employeeId}`);

    return {
      success: true,
      message: 'Logout successful',
    };
  }
}
