import { Injectable, NotFoundException } from '@nestjs/common';
import { ApiSuccessResponse } from '../common/interfaces/api-response.interface';
import {
  CustomerDeviceItem,
  toCustomerDeviceItem,
} from './customer-device.mapper';
import { CustomerDeviceRepository } from './customer-device.repository';
import { CustomerRepository } from './customer.repository';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateDeviceDto } from './dto/update-device.dto';
import { mapApiPlatformToPrisma } from './utils/customer-device-meta.util';

@Injectable()
export class CustomerDeviceService {
  constructor(
    private readonly customerRepository: CustomerRepository,
    private readonly deviceRepository: CustomerDeviceRepository,
  ) {}

  async findAll(
    customerId: string,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem[]>> {
    await this.ensureCustomerExists(customerId);

    const devices = await this.deviceRepository.findByCustomerId(customerId);

    return {
      success: true,
      message: 'Customer devices retrieved successfully',
      data: devices.map((device) => toCustomerDeviceItem(device)),
    };
  }

  async findOne(
    customerId: string,
    deviceId: string,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem>> {
    await this.ensureCustomerExists(customerId);

    const device = await this.deviceRepository.findById(customerId, deviceId);

    if (!device) {
      throw new NotFoundException('Customer device not found');
    }

    return {
      success: true,
      message: 'Customer device retrieved successfully',
      data: toCustomerDeviceItem(device),
    };
  }

  async register(
    customerId: string,
    dto: RegisterDeviceDto,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem>> {
    await this.ensureCustomerExists(customerId);

    const deviceToken = dto.deviceToken.trim();
    const platform = mapApiPlatformToPrisma(dto.devicePlatform);

    const device = await this.deviceRepository.register(
      customerId,
      deviceToken,
      platform,
    );

    return {
      success: true,
      message: 'Customer device registered successfully',
      data: toCustomerDeviceItem(device, {
        deviceName: dto.deviceName,
        appVersion: dto.appVersion,
        osVersion: dto.osVersion,
        devicePlatform: dto.devicePlatform,
      }),
    };
  }

  async update(
    customerId: string,
    deviceId: string,
    dto: UpdateDeviceDto,
  ): Promise<ApiSuccessResponse<CustomerDeviceItem>> {
    await this.ensureCustomerExists(customerId);

    const existing = await this.deviceRepository.findById(customerId, deviceId);

    if (!existing) {
      throw new NotFoundException('Customer device not found');
    }

    if (dto.deviceToken) {
      const tokenOwner = await this.deviceRepository.findByToken(
        dto.deviceToken.trim(),
      );

      if (tokenOwner && tokenOwner.id !== deviceId) {
        await this.deviceRepository.softDelete(tokenOwner.id);
      }
    }

    const device = await this.deviceRepository.update(deviceId, {
      ...(dto.deviceToken !== undefined && {
        deviceToken: dto.deviceToken.trim(),
      }),
      ...(dto.devicePlatform !== undefined && {
        platform: mapApiPlatformToPrisma(dto.devicePlatform),
      }),
    });

    return {
      success: true,
      message: 'Customer device updated successfully',
      data: toCustomerDeviceItem(device, {
        deviceName: dto.deviceName,
        appVersion: dto.appVersion,
        osVersion: dto.osVersion,
        devicePlatform: dto.devicePlatform,
      }),
    };
  }

  async remove(
    customerId: string,
    deviceId: string,
  ): Promise<ApiSuccessResponse<null>> {
    await this.ensureCustomerExists(customerId);

    const existing = await this.deviceRepository.findById(customerId, deviceId);

    if (!existing) {
      throw new NotFoundException('Customer device not found');
    }

    await this.deviceRepository.softDelete(deviceId);

    return {
      success: true,
      message: 'Customer device unregistered successfully',
      data: null,
    };
  }

  private async ensureCustomerExists(customerId: string): Promise<void> {
    const customer = await this.customerRepository.findById(customerId);

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }
  }
}
