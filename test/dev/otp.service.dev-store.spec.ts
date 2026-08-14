import { ConfigService } from '@nestjs/config';
import { OtpPurpose } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { DevOtpPlaintextStore } from '../../src/dev/dev-otp-plaintext.store';
import { OtpRepository } from '../../src/auth/otp/otp.repository';
import { OtpService } from '../../src/auth/otp/otp.service';
import { CustomerRepository } from '../../src/customer/customer.repository';

jest.mock('bcrypt', () => ({
  hash: jest.fn(),
  compare: jest.fn(),
}));

describe('OtpService issueOtpRecord', () => {
  const otpRepository = {
    createOtp: jest.fn(),
  };
  const customerRepository = {
    findActiveByPhone: jest.fn(),
    findByPhone: jest.fn(),
  };
  const jwtService = {};
  const configService = {
    get: jest.fn().mockReturnValue('development'),
  };
  const devOtpPlaintextStore = {
    remember: jest.fn(),
  };

  let service: OtpService;

  beforeEach(() => {
    jest.clearAllMocks();
    (bcrypt.hash as jest.Mock).mockResolvedValue('hashed-code');

    service = new OtpService(
      otpRepository as unknown as OtpRepository,
      customerRepository as unknown as CustomerRepository,
      jwtService as never,
      configService as unknown as ConfigService,
      devOtpPlaintextStore as unknown as DevOtpPlaintextStore,
    );
  });

  it('stores plaintext OTP in development cache', async () => {
    const expiresAt = new Date(Date.now() + 300_000);
    customerRepository.findActiveByPhone.mockResolvedValue({ id: 'cust-1' });
    otpRepository.createOtp.mockResolvedValue({
      id: 'otp-1',
      expiresAt,
    });

    const issued = await service.issueOtpRecord('081234567890', OtpPurpose.login);

    expect(issued.code).toMatch(/^\d{6}$/);
    expect(devOtpPlaintextStore.remember).toHaveBeenCalledWith(
      'otp-1',
      issued.code,
      expect.any(Date),
    );
  });

  it('does not store plaintext OTP in production', async () => {
    configService.get.mockReturnValue('production');
    const expiresAt = new Date(Date.now() + 300_000);
    customerRepository.findActiveByPhone.mockResolvedValue({ id: 'cust-1' });
    otpRepository.createOtp.mockResolvedValue({
      id: 'otp-1',
      expiresAt,
    });

    await service.issueOtpRecord('081234567890', OtpPurpose.login);

    expect(devOtpPlaintextStore.remember).not.toHaveBeenCalled();
  });
});
