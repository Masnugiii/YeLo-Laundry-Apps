import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { OtpPurpose, OtpStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomInt } from 'crypto';
import { ApiSuccessResponse } from '../../common/interfaces/api-response.interface';
import { CustomerRepository } from '../../customer/customer.repository';
import { toCustomerDetail } from '../../customer/customer.mapper';
import { CustomerRegisterDto } from '../dto/customer-register.dto';
import {
  CustomerAuthResponseDto,
  SendOtpResponseDto,
} from '../dto/customer-auth-response.dto';
import {
  CustomerProfileResponseDto,
  UpdateCustomerProfileDto,
} from '../dto/customer-profile.dto';
import { SendOtpDto } from '../dto/send-otp.dto';
import { VerifyOtpDto } from '../dto/verify-otp.dto';
import {
  RequestChangePhoneDto,
  VerifyChangePhoneDto,
} from '../dto/change-phone.dto';
import { CustomerJwtPayload } from '../interfaces/jwt-payload.interface';
import { normalizePhone } from '../utils/phone.util';
import { parseDurationToMs } from '../utils/token.util';
import { OtpRepository } from './otp.repository';
import { DevOtpPlaintextStore } from '../../dev/dev-otp-plaintext.store';

const BCRYPT_ROUNDS = 10;
const OTP_EXPIRY_SECONDS = 300;
const OTP_RATE_LIMIT = 3;
const OTP_RATE_WINDOW_MS = 15 * 60 * 1000;
const MAX_OTP_ATTEMPTS = 5;

export interface IssuedOtpRecord {
  otp: Awaited<ReturnType<OtpRepository['createOtp']>>;
  code: string;
  expiresIn: number;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(
    private readonly otpRepository: OtpRepository,
    private readonly customerRepository: CustomerRepository,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly devOtpPlaintextStore: DevOtpPlaintextStore,
  ) {}

  async issueOtpRecord(
    phone: string,
    purpose: OtpPurpose,
  ): Promise<IssuedOtpRecord> {
    if (purpose === OtpPurpose.login) {
      const customer = await this.customerRepository.findActiveByPhone(phone);

      if (!customer) {
        throw new NotFoundException('Customer account not found');
      }
    }

    if (purpose === OtpPurpose.register) {
      const existing = await this.customerRepository.findByPhone(phone);

      if (existing) {
        throw new ConflictException('Phone number already registered');
      }
    }

    if (purpose === OtpPurpose.phone_change) {
      const existing = await this.customerRepository.findByPhone(phone);

      if (existing) {
        throw new ConflictException('Phone number already registered');
      }
    }

    const code = randomInt(100000, 999999).toString();
    const codeHash = await bcrypt.hash(code, BCRYPT_ROUNDS);
    const expiresAt = new Date(Date.now() + OTP_EXPIRY_SECONDS * 1000);

    const otp = await this.otpRepository.createOtp({
      phone,
      codeHash,
      purpose,
      expiresAt,
    });

    if (this.configService.get<string>('app.env') !== 'production') {
      this.devOtpPlaintextStore.remember(otp.id, code, expiresAt);
    }

    return {
      otp,
      code,
      expiresIn: OTP_EXPIRY_SECONDS,
    };
  }

  async sendOtp(
    dto: SendOtpDto,
  ): Promise<ApiSuccessResponse<SendOtpResponseDto>> {
    const phone = normalizePhone(dto.phone);
    const since = new Date(Date.now() - OTP_RATE_WINDOW_MS);
    const recentCount = await this.otpRepository.countRecentByPhone(phone, since);

    if (recentCount >= OTP_RATE_LIMIT) {
      throw new HttpException(
        'Too many OTP requests. Please try again later.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const issued = await this.issueOtpRecord(phone, dto.purpose);

    if (this.configService.get<string>('app.env') !== 'production') {
      this.logger.debug(
        `OTP reference for ${this.maskPhone(phone)} purpose=${dto.purpose}: ${issued.code}`,
      );
    }

    return {
      success: true,
      message: 'OTP sent successfully',
      data: {
        otpRequestId: issued.otp.id,
        expiresIn: issued.expiresIn,
        maskedPhone: this.maskPhone(phone),
      },
    };
  }

  async verifyOtp(
    dto: VerifyOtpDto,
  ): Promise<ApiSuccessResponse<CustomerAuthResponseDto>> {
    const phone = normalizePhone(dto.phone);
    const otp = await this.validateOtpRequest(dto.otpRequestId, phone, dto.otpCode);

    if (otp.purpose !== OtpPurpose.login) {
      throw new BadRequestException(
        'OTP purpose mismatch. Use customer registration for new accounts.',
      );
    }

    const customer = await this.customerRepository.findActiveByPhone(phone);

    if (!customer) {
      throw new NotFoundException('Customer account not found');
    }

    await this.otpRepository.markVerified(otp.id);

    return {
      success: true,
      message: 'OTP verified successfully',
      data: await this.issueCustomerTokens(customer.id, customer.phone, {
        fullName: customer.fullName,
        email: customer.email,
        photoUrl: customer.photoUrl,
        customerCode: customer.customerCode,
      }),
    };
  }

  async registerCustomer(
    dto: CustomerRegisterDto,
  ): Promise<ApiSuccessResponse<CustomerAuthResponseDto>> {
    const phone = normalizePhone(dto.phone);
    const otp = await this.validateOtpRequest(
      dto.otpRequestId,
      phone,
      dto.otpCode,
    );

    if (otp.purpose !== OtpPurpose.register) {
      throw new BadRequestException('OTP purpose mismatch for registration');
    }

    const existing = await this.customerRepository.findByPhone(phone);

    if (existing) {
      throw new ConflictException('Phone number already registered');
    }

    const customerCode =
      await this.customerRepository.generateNextCustomerCode();

    const customer = await this.customerRepository.createWithWallet({
      customerCode,
      fullName: dto.fullName.trim(),
      phone,
      email: dto.email?.trim().toLowerCase() ?? null,
      gender: dto.gender,
      age: dto.age,
      occupation: dto.occupation.trim(),
      isActive: true,
    });

    await this.otpRepository.markVerified(otp.id);

    this.logger.log(`Customer registered via app: ${customer.id}`);

    return {
      success: true,
      message: 'Registration successful',
      data: await this.issueCustomerTokens(customer.id, customer.phone, {
        fullName: customer.fullName,
        email: customer.email,
        photoUrl: customer.photoUrl,
        customerCode: customer.customerCode,
      }),
    };
  }

  async getCustomerProfile(
    customerId: string,
  ): Promise<ApiSuccessResponse<CustomerProfileResponseDto>> {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    const detail = toCustomerDetail(customer);

    return {
      success: true,
      message: 'Profile loaded successfully',
      data: {
        id: detail.id,
        customerCode: detail.customerCode,
        fullName: detail.fullName,
        phone: detail.phone,
        email: detail.email,
        gender: detail.gender,
        birthDate: detail.birthDate?.toISOString() ?? null,
        photoUrl: detail.photoUrl,
        occupation: customer.occupation,
        loyaltyPoints: detail.loyaltyPoints,
        walletBalance: detail.walletBalance,
      },
    };
  }

  async updateCustomerProfile(
    customerId: string,
    dto: UpdateCustomerProfileDto,
  ): Promise<ApiSuccessResponse<CustomerProfileResponseDto>> {
    const existing = await this.customerRepository.findById(customerId);

    if (!existing) {
      throw new NotFoundException('Customer not found');
    }

    if (dto.email) {
      const emailOwner = await this.customerRepository.findByEmail(
        dto.email.trim().toLowerCase(),
        customerId,
      );

      if (emailOwner) {
        throw new ConflictException('Email already exists');
      }
    }

    await this.customerRepository.update(customerId, {
      ...(dto.fullName !== undefined && { fullName: dto.fullName.trim() }),
      ...(dto.email !== undefined && {
        email: dto.email ? dto.email.trim().toLowerCase() : null,
      }),
      ...(dto.photoUrl !== undefined && { photoUrl: dto.photoUrl }),
      ...(dto.birthDate !== undefined && { birthDate: dto.birthDate }),
      ...(dto.occupation !== undefined && {
        occupation: dto.occupation.trim() || null,
      }),
    });

    return this.getCustomerProfile(customerId);
  }

  async requestCustomerPhoneChange(
    customerId: string,
    dto: RequestChangePhoneDto,
  ): Promise<ApiSuccessResponse<SendOtpResponseDto>> {
    const phone = normalizePhone(dto.phone);
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    if (normalizePhone(customer.phone) === phone) {
      throw new BadRequestException(
        'New phone number must be different from the current number',
      );
    }

    const duplicate = await this.customerRepository.findByPhone(phone, customerId);

    if (duplicate) {
      throw new ConflictException('Phone number already registered');
    }

    const since = new Date(Date.now() - OTP_RATE_WINDOW_MS);
    const recentCount = await this.otpRepository.countRecentByPhone(phone, since);

    if (recentCount >= OTP_RATE_LIMIT) {
      throw new HttpException(
        'Too many OTP requests. Please try again later.',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const issued = await this.issueOtpRecord(phone, OtpPurpose.phone_change);

    if (this.configService.get<string>('app.env') !== 'production') {
      this.logger.debug(
        `OTP reference for ${this.maskPhone(phone)} purpose=${OtpPurpose.phone_change}: ${issued.code}`,
      );
    }

    return {
      success: true,
      message: 'OTP sent successfully',
      data: {
        otpRequestId: issued.otp.id,
        expiresIn: issued.expiresIn,
        maskedPhone: this.maskPhone(phone),
      },
    };
  }

  async verifyCustomerPhoneChange(
    customerId: string,
    dto: VerifyChangePhoneDto,
  ): Promise<ApiSuccessResponse<CustomerProfileResponseDto>> {
    const phone = normalizePhone(dto.phone);
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    if (normalizePhone(customer.phone) === phone) {
      throw new BadRequestException(
        'New phone number must be different from the current number',
      );
    }

    const duplicate = await this.customerRepository.findByPhone(phone, customerId);

    if (duplicate) {
      throw new ConflictException('Phone number already registered');
    }

    const otp = await this.validateOtpRequest(
      dto.otpRequestId,
      phone,
      dto.otpCode,
    );

    if (otp.purpose !== OtpPurpose.phone_change) {
      throw new BadRequestException('OTP purpose mismatch for phone change');
    }

    await this.otpRepository.markVerified(otp.id);

    await this.customerRepository.update(customerId, { phone });

    return this.getCustomerProfile(customerId);
  }

  async refreshCustomerToken(
    refreshToken: string,
  ): Promise<ApiSuccessResponse<{ accessToken: string; refreshToken: string }>> {
    let payload: CustomerJwtPayload;

    try {
      payload = this.jwtService.verify<CustomerJwtPayload>(refreshToken, {
        secret: this.configService.getOrThrow<string>('jwt.secret'),
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    if (
      payload.actorType !== 'customer' ||
      payload.tokenType !== 'refresh' ||
      !payload.customerId
    ) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const customer = await this.customerRepository.findById(payload.customerId);

    if (!customer || !customer.isActive) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    const tokens = await this.issueCustomerTokens(
      customer.id,
      customer.phone,
      {
        fullName: customer.fullName,
        email: customer.email,
        photoUrl: customer.photoUrl,
        customerCode: customer.customerCode,
      },
    );

    return {
      success: true,
      message: 'Token refreshed successfully',
      data: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      },
    };
  }

  private async validateOtpRequest(
    otpRequestId: string,
    phone: string,
    otpCode: string,
  ) {
    const otp = await this.otpRepository.findById(otpRequestId);

    if (!otp || otp.phone !== phone) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    if (otp.status !== OtpStatus.pending) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    if (otp.expiresAt < new Date()) {
      await this.otpRepository.markExpired(otp.id);
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    if (otp.attempts >= MAX_OTP_ATTEMPTS) {
      await this.otpRepository.markFailed(otp.id);
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    const isValid = await bcrypt.compare(otpCode, otp.codeHash);

    if (!isValid) {
      await this.otpRepository.incrementAttempts(otp.id);
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    return otp;
  }

  private async issueCustomerTokens(
    customerId: string,
    phone: string,
    profile: {
      fullName: string;
      email: string | null;
      photoUrl: string | null;
      customerCode: string;
    },
  ): Promise<CustomerAuthResponseDto> {
    const accessExpiresIn = this.configService.get<string>('jwt.expiresIn', '7d');
    const refreshExpiresIn = this.configService.get<string>(
      'jwt.refreshExpiresIn',
      '30d',
    );

    const accessPayload: CustomerJwtPayload = {
      actorType: 'customer',
      customerId,
      phone,
      tokenType: 'access',
    };

    const refreshPayload: CustomerJwtPayload = {
      actorType: 'customer',
      customerId,
      phone,
      tokenType: 'refresh',
    };

    const accessToken = this.jwtService.sign(accessPayload, {
      expiresIn: accessExpiresIn as `${number}d`,
    });

    const refreshToken = this.jwtService.sign(refreshPayload, {
      expiresIn: refreshExpiresIn as `${number}d`,
    });

    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: Math.floor(parseDurationToMs(accessExpiresIn) / 1000),
      user: {
        id: customerId,
        phone,
        fullName: profile.fullName,
        email: profile.email,
        photoUrl: profile.photoUrl,
        customerCode: profile.customerCode,
      },
    };
  }

  private maskPhone(phone: string): string {
    if (phone.length < 8) {
      return phone;
    }

    return `${phone.slice(0, 5)}****${phone.slice(-4)}`;
  }
}
