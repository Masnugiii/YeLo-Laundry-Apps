import { NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OtpPurpose } from '@prisma/client';
import { DevOtpService } from '../../src/dev/dev-otp.service';
import { DevOtpPlaintextStore } from '../../src/dev/dev-otp-plaintext.store';
import { OtpRepository } from '../../src/auth/otp/otp.repository';
import { OtpService } from '../../src/auth/otp/otp.service';
import { CustomerRepository } from '../../src/customer/customer.repository';

describe('DevOtpService', () => {
  const configService = {
    get: jest.fn(),
  };
  const otpService = {
    issueOtpRecord: jest.fn(),
  };
  const otpRepository = {
    findLatestPendingByPhone: jest.fn(),
  };
  const customerRepository = {
    findActiveByPhone: jest.fn(),
    findByPhone: jest.fn(),
  };
  const devOtpPlaintextStore = {
    get: jest.fn(),
    remember: jest.fn(),
  };

  let service: DevOtpService;

  beforeEach(() => {
    jest.clearAllMocks();
    configService.get.mockImplementation((key: string) => {
      if (key === 'app.env') return 'development';
      if (key === 'dev.otpPhoneWhitelist') return '081234567890';
      return undefined;
    });

    service = new DevOtpService(
      configService as unknown as ConfigService,
      otpService as unknown as OtpService,
      otpRepository as unknown as OtpRepository,
      customerRepository as unknown as CustomerRepository,
      devOtpPlaintextStore as unknown as DevOtpPlaintextStore,
    );
  });

  it('returns 404 behavior in production', async () => {
    configService.get.mockImplementation((key: string) => {
      if (key === 'app.env') return 'production';
      return undefined;
    });

    await expect(
      service.generate({ phone: '081234567890', purpose: OtpPurpose.login }),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('rejects non-whitelisted phone numbers', async () => {
    await expect(
      service.generate({ phone: '081900000001', purpose: OtpPurpose.login }),
    ).rejects.toMatchObject({ status: 403 });
  });

  it('reveals an existing pending OTP created by customer send', async () => {
    const expiresAt = new Date(Date.now() + 120_000);
    customerRepository.findActiveByPhone.mockResolvedValue({ id: 'cust-1' });
    otpRepository.findLatestPendingByPhone.mockResolvedValue({
      id: 'otp-1',
      expiresAt,
    });
    devOtpPlaintextStore.get.mockReturnValue('482731');

    const response = await service.generate({
      phone: '081234567890',
      purpose: OtpPurpose.login,
    });

    expect(response.data?.otp).toBe('482731');
    expect(response.data?.phone).toBe('081234567890');
    expect(otpService.issueOtpRecord).not.toHaveBeenCalled();
  });

  it('creates a new OTP when no pending OTP is available', async () => {
    const expiresAt = new Date(Date.now() + 300_000);
    customerRepository.findActiveByPhone.mockResolvedValue({ id: 'cust-1' });
    otpRepository.findLatestPendingByPhone.mockResolvedValue(null);
    otpService.issueOtpRecord.mockResolvedValue({
      otp: { id: 'otp-2', expiresAt },
      code: '123456',
      expiresIn: 300,
    });

    const response = await service.generate({
      phone: '081234567890',
      purpose: OtpPurpose.login,
    });

    expect(response.data?.otp).toBe('123456');
    expect(devOtpPlaintextStore.remember).toHaveBeenCalledWith(
      'otp-2',
      '123456',
      expiresAt,
    );
  });
});
