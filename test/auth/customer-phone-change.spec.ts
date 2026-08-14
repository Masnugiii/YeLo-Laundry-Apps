import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { OtpPurpose } from '@prisma/client';
import { OtpRepository } from '../../src/auth/otp/otp.repository';
import { OtpService } from '../../src/auth/otp/otp.service';
import { CustomerRepository } from '../../src/customer/customer.repository';
import { DevOtpPlaintextStore } from '../../src/dev/dev-otp-plaintext.store';

describe('OtpService customer phone change', () => {
  const otpRepository = {
    countRecentByPhone: jest.fn(),
    createOtp: jest.fn(),
    findById: jest.fn(),
    markVerified: jest.fn(),
    incrementAttempts: jest.fn(),
    markExpired: jest.fn(),
    markFailed: jest.fn(),
  };
  const customerRepository = {
    findById: jest.fn(),
    findByPhone: jest.fn(),
    update: jest.fn(),
  };
  const jwtService = {
    sign: jest.fn().mockReturnValue('token'),
  };
  const configService = {
    get: jest.fn((key: string, fallback?: string) => {
      if (key === 'app.env') return 'test';
      if (key === 'jwt.expiresIn') return fallback ?? '7d';
      if (key === 'jwt.refreshExpiresIn') return fallback ?? '30d';
      return fallback;
    }),
    getOrThrow: jest.fn().mockReturnValue('secret'),
  };
  const devOtpPlaintextStore = {
    remember: jest.fn(),
  };

  let service: OtpService;

  beforeEach(() => {
    jest.clearAllMocks();

    service = new OtpService(
      otpRepository as unknown as OtpRepository,
      customerRepository as unknown as CustomerRepository,
      jwtService as unknown as JwtService,
      configService as unknown as ConfigService,
      devOtpPlaintextStore as unknown as DevOtpPlaintextStore,
    );
  });

  const activeCustomer = {
    id: 'cust-1',
    customerCode: 'CUS-0001',
    fullName: 'Test Customer',
    phone: '081234567890',
    email: null,
    gender: null,
    birthDate: null,
    occupation: null,
    photoUrl: null,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
    wallet: {
      currentBalance: 0,
      currency: 'IDR',
      isActive: true,
    },
    rewardPoints: [],
    defaultAddress: null,
    addresses: [],
  };

  it('rejects requesting OTP for the current phone number', async () => {
    customerRepository.findById.mockResolvedValue(activeCustomer);

    await expect(
      service.requestCustomerPhoneChange('cust-1', {
        phone: '081234567890',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects duplicate phone numbers', async () => {
    customerRepository.findById.mockResolvedValue(activeCustomer);
    customerRepository.findByPhone.mockResolvedValue({ id: 'cust-2' });

    await expect(
      service.requestCustomerPhoneChange('cust-1', {
        phone: '081234567891',
      }),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('requests OTP for a valid new phone number', async () => {
    customerRepository.findById.mockResolvedValue(activeCustomer);
    customerRepository.findByPhone.mockResolvedValue(null);
    otpRepository.countRecentByPhone.mockResolvedValue(0);
    otpRepository.createOtp.mockResolvedValue({
      id: 'otp-1',
      expiresAt: new Date(Date.now() + 60_000),
    });

    const response = await service.requestCustomerPhoneChange('cust-1', {
      phone: '081234567891',
    });

    expect(response.data?.otpRequestId).toBe('otp-1');
    expect(otpRepository.createOtp).toHaveBeenCalledWith(
      expect.objectContaining({
        phone: '081234567891',
        purpose: OtpPurpose.phone_change,
      }),
    );
  });

  it('updates only the authenticated customer after OTP verification', async () => {
    const updatedCustomer = {
      ...activeCustomer,
      phone: '081234567891',
    };

    customerRepository.findById
      .mockResolvedValueOnce(activeCustomer)
      .mockResolvedValueOnce(updatedCustomer);
    customerRepository.findByPhone.mockResolvedValue(null);
    otpRepository.findById.mockResolvedValue({
      id: 'otp-1',
      phone: '081234567891',
      purpose: OtpPurpose.phone_change,
      status: 'pending',
      expiresAt: new Date(Date.now() + 60_000),
      attempts: 0,
      codeHash: '$2b$10$abcdefghijklmnopqrstuv',
    });
    otpRepository.markVerified.mockResolvedValue(undefined);
    customerRepository.update.mockResolvedValue(updatedCustomer);

    jest.spyOn(service, 'validateOtpRequest' as never).mockResolvedValue({
      id: 'otp-1',
      phone: '081234567891',
      purpose: OtpPurpose.phone_change,
    } as never);

    const response = await service.verifyCustomerPhoneChange('cust-1', {
      phone: '081234567891',
      otpRequestId: 'otp-1',
      otpCode: '123456',
    });

    expect(customerRepository.update).toHaveBeenCalledWith('cust-1', {
      phone: '081234567891',
    });
    expect(response.data?.phone).toBe('081234567891');
  });

  it('rejects OTP purpose mismatch during verification', async () => {
    customerRepository.findById.mockResolvedValue(activeCustomer);
    customerRepository.findByPhone.mockResolvedValue(null);
    jest.spyOn(service, 'validateOtpRequest' as never).mockResolvedValue({
      id: 'otp-1',
      phone: '081234567891',
      purpose: OtpPurpose.login,
    } as never);

    await expect(
      service.verifyCustomerPhoneChange('cust-1', {
        phone: '081234567891',
        otpRequestId: 'otp-1',
        otpCode: '123456',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects phone change for missing customers', async () => {
    customerRepository.findById.mockResolvedValue(null);

    await expect(
      service.requestCustomerPhoneChange('missing', {
        phone: '081234567891',
      }),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('does not expose another customer when verifying phone change', async () => {
    customerRepository.findById.mockResolvedValue(activeCustomer);
    customerRepository.findByPhone.mockResolvedValue(null);
    jest.spyOn(service, 'validateOtpRequest' as never).mockResolvedValue({
      id: 'otp-1',
      phone: '081234567891',
      purpose: OtpPurpose.phone_change,
    } as never);

    await service.verifyCustomerPhoneChange('cust-1', {
      phone: '081234567891',
      otpRequestId: 'otp-1',
      otpCode: '123456',
    });

    expect(customerRepository.update).toHaveBeenCalledWith('cust-1', {
      phone: '081234567891',
    });
    expect(customerRepository.update).not.toHaveBeenCalledWith(
      'cust-2',
      expect.anything(),
    );
  });
});
