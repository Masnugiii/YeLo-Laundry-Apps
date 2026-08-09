import { Injectable } from '@nestjs/common';
import { DevicePlatform, Prisma } from '@prisma/client';
import { PrismaService } from '../database/prisma/prisma.service';
import { customerDeviceSelect } from './customer-device.select';

@Injectable()
export class CustomerDeviceRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByCustomerId(customerId: string) {
    return this.prisma.customerDevice.findMany({
      where: { customerId, deletedAt: null },
      orderBy: [{ lastLoginAt: 'desc' }, { createdAt: 'desc' }],
      select: customerDeviceSelect,
    });
  }

  findById(customerId: string, deviceId: string) {
    return this.prisma.customerDevice.findFirst({
      where: { id: deviceId, customerId, deletedAt: null },
      select: customerDeviceSelect,
    });
  }

  findByToken(deviceToken: string) {
    return this.prisma.customerDevice.findFirst({
      where: { deviceToken },
      select: customerDeviceSelect,
    });
  }

  register(
    customerId: string,
    deviceToken: string,
    platform: DevicePlatform,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const existing = await tx.customerDevice.findFirst({
        where: { deviceToken },
        select: customerDeviceSelect,
      });

      if (existing) {
        return tx.customerDevice.update({
          where: { id: existing.id },
          data: {
            customerId,
            platform,
            deletedAt: null,
            lastLoginAt: new Date(),
          },
          select: customerDeviceSelect,
        });
      }

      return tx.customerDevice.create({
        data: {
          customerId,
          deviceToken,
          platform,
          lastLoginAt: new Date(),
        },
        select: customerDeviceSelect,
      });
    });
  }

  update(
    deviceId: string,
    data: Prisma.CustomerDeviceUpdateInput,
  ) {
    return this.prisma.customerDevice.update({
      where: { id: deviceId },
      data: {
        ...data,
        lastLoginAt: new Date(),
      },
      select: customerDeviceSelect,
    });
  }

  softDelete(deviceId: string) {
    return this.prisma.customerDevice.update({
      where: { id: deviceId },
      data: { deletedAt: new Date() },
      select: { id: true },
    });
  }
}
