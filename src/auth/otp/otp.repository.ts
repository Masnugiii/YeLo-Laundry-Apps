import { Injectable } from '@nestjs/common';
import { OtpPurpose, OtpStatus } from '@prisma/client';
import { PrismaService } from '../../database/prisma/prisma.service';

@Injectable()
export class OtpRepository {
  constructor(private readonly prisma: PrismaService) {}

  countRecentByPhone(phone: string, since: Date) {
    return this.prisma.otpCode.count({
      where: {
        phone,
        createdAt: { gte: since },
        deletedAt: null,
      },
    });
  }

  createOtp(data: {
    phone: string;
    codeHash: string;
    purpose: OtpPurpose;
    expiresAt: Date;
  }) {
    return this.prisma.otpCode.create({
      data: {
        phone: data.phone,
        codeHash: data.codeHash,
        purpose: data.purpose,
        status: OtpStatus.pending,
        expiresAt: data.expiresAt,
      },
    });
  }

  findById(id: string) {
    return this.prisma.otpCode.findFirst({
      where: { id, deletedAt: null },
    });
  }

  incrementAttempts(id: string) {
    return this.prisma.otpCode.update({
      where: { id },
      data: { attempts: { increment: 1 } },
    });
  }

  markVerified(id: string) {
    return this.prisma.otpCode.update({
      where: { id },
      data: {
        status: OtpStatus.verified,
        verifiedAt: new Date(),
      },
    });
  }

  markFailed(id: string) {
    return this.prisma.otpCode.update({
      where: { id },
      data: { status: OtpStatus.failed },
    });
  }

  markExpired(id: string) {
    return this.prisma.otpCode.update({
      where: { id },
      data: { status: OtpStatus.expired },
    });
  }
}
