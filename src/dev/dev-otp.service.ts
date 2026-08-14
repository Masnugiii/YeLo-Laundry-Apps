import {
  ConflictException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OtpPurpose } from '@prisma/client';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import { CustomerRepository } from '../customer/customer.repository';
import { OtpRepository } from '../auth/otp/otp.repository';
import { OtpService } from '../auth/otp/otp.service';
import { normalizePhone } from '../auth/utils/phone.util';
import {
  DEV_OTP_GENERATE_RATE_LIMIT,
  DEV_OTP_GENERATE_WINDOW_MS,
  parseDevOtpPhoneWhitelist,
} from './dev-otp.config';
import { DevOtpPlaintextStore } from './dev-otp-plaintext.store';
import {
  DevGenerateOtpDto,
  DevGenerateOtpResponseDto,
} from './dto/dev-generate-otp.dto';

@Injectable()
export class DevOtpService {
  private readonly generateAttempts = new Map<string, number[]>();

  constructor(
    private readonly configService: ConfigService,
    private readonly otpService: OtpService,
    private readonly otpRepository: OtpRepository,
    private readonly customerRepository: CustomerRepository,
    private readonly devOtpPlaintextStore: DevOtpPlaintextStore,
  ) {}

  async generate(
    dto: DevGenerateOtpDto,
  ): Promise<ApiSuccessResponse<DevGenerateOtpResponseDto>> {
    this.assertDevEnvironment();

    const phone = normalizePhone(dto.phone);
    this.assertWhitelistedPhone(phone);
    this.assertGenerateRateLimit(phone);
    await this.assertPurposePreconditions(phone, dto.purpose);

    const pending = await this.otpRepository.findLatestPendingByPhone(
      phone,
      dto.purpose,
    );

    if (pending) {
      const existingCode = this.devOtpPlaintextStore.get(pending.id);
      if (existingCode) {
        return this.successResponse(
          phone,
          existingCode,
          pending.expiresAt,
        );
      }
    }

    const issued = await this.otpService.issueOtpRecord(phone, dto.purpose);
    this.devOtpPlaintextStore.remember(
      issued.otp.id,
      issued.code,
      issued.otp.expiresAt,
    );

    return this.successResponse(phone, issued.code, issued.otp.expiresAt);
  }

  private assertDevEnvironment(): void {
    if (this.configService.get<string>('app.env') === 'production') {
      throw new NotFoundException();
    }
  }

  private assertWhitelistedPhone(phone: string): void {
    const whitelist = parseDevOtpPhoneWhitelist(
      this.configService.get<string>('dev.otpPhoneWhitelist'),
    );

    if (!whitelist.has(phone)) {
      throw new ForbiddenException(
        'Phone number is not allowed for development OTP testing.',
      );
    }
  }

  private assertGenerateRateLimit(phone: string): void {
    const now = Date.now();
    const windowStart = now - DEV_OTP_GENERATE_WINDOW_MS;
    const attempts = (this.generateAttempts.get(phone) ?? []).filter(
      (timestamp) => timestamp >= windowStart,
    );

    if (attempts.length >= DEV_OTP_GENERATE_RATE_LIMIT) {
      throw new HttpException(
        'Too many development OTP generation requests. Please try again later.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    attempts.push(now);
    this.generateAttempts.set(phone, attempts);
  }

  private async assertPurposePreconditions(
    phone: string,
    purpose: OtpPurpose,
  ): Promise<void> {
    if (purpose === OtpPurpose.login) {
      const customer = await this.customerRepository.findActiveByPhone(phone);
      if (!customer) {
        throw new NotFoundException('Customer account not found');
      }
      return;
    }

    if (purpose === OtpPurpose.register) {
      const existing = await this.customerRepository.findByPhone(phone);
      if (existing) {
        throw new ConflictException('Phone number already registered');
      }
    }
  }

  private successResponse(
    phone: string,
    otp: string,
    expiresAt: Date,
  ): ApiSuccessResponse<DevGenerateOtpResponseDto> {
    const expiresIn = Math.max(
      0,
      Math.floor((expiresAt.getTime() - Date.now()) / 1000),
    );

    return {
      success: true,
      message: 'Development OTP generated successfully',
      data: {
        phone,
        otp,
        expiresIn,
      },
    };
  }
}
