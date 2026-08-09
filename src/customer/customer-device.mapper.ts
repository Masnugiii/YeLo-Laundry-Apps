import { DevicePlatform } from '@prisma/client';
import { CustomerDeviceRecord } from './customer-device.select';
import {
  CustomerDeviceMeta,
  DevicePlatformApi,
  mapPrismaPlatformToApi,
  maskDeviceToken,
} from './utils/customer-device-meta.util';

export interface CustomerDeviceItem {
  id: string;
  customerId: string;
  deviceName: string | null;
  devicePlatform: DevicePlatformApi;
  maskedDeviceToken: string;
  appVersion: string | null;
  osVersion: string | null;
  lastActiveAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

export function toCustomerDeviceItem(
  device: CustomerDeviceRecord,
  extras?: Partial<CustomerDeviceMeta> & { devicePlatform?: DevicePlatformApi },
): CustomerDeviceItem {
  return {
    id: device.id,
    customerId: device.customerId,
    deviceName: extras?.deviceName ?? null,
    devicePlatform: mapPrismaPlatformToApi(
      device.platform,
      extras?.devicePlatform,
    ),
    maskedDeviceToken: maskDeviceToken(device.deviceToken),
    appVersion: extras?.appVersion ?? null,
    osVersion: extras?.osVersion ?? null,
    lastActiveAt: device.lastLoginAt,
    createdAt: device.createdAt,
    updatedAt: device.updatedAt,
  };
}
